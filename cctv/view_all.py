import cv2
import numpy as np
import threading
import time

# Replace these URLs with your actual RTSP streams
rtsp_urls = [
    "rtsp://dd-front-door:<password>@192.168.0.102/stream2",
    "rtsp://koki-front-door:<password>@192.168.0.105/stream2",
    "rtsp://dd-back-door:<password>@192.168.0.103/stream2",
    "rtsp://dd-garage:<password>@192.168.0.104/stream2",
]

#    "rtsp://koki-front-door:<password>@192.168.0.105/stream2"

# Set target dimensions for each quadrant (width, height)
TARGET_WIDTH = 640  # Half of 1280 window width
TARGET_HEIGHT = 360  # Half of 720 window height
BORDER_COLOR = (116, 147, 56)  # Green border (BGR format)
BORDER_SIZE = 2  # Border thickness in pixels

# Global variables for frames and locks
frames = [None] * 4
locks = [threading.Lock() for _ in range(4)]

# Flag to control threads
running = True

def add_border(frame, border_size, border_color):
    """Add a border around the frame."""
    return cv2.copyMakeBorder(
        frame,
        top=border_size,
        bottom=border_size,
        left=border_size,
        right=border_size,
        borderType=cv2.BORDER_CONSTANT,
        value=border_color
    )

def rotate_frame(frame, angle):
    """Rotate the frame by a given angle."""
    (h, w) = frame.shape[:2]
    center = (w // 2, h // 2)
    rotation_matrix = cv2.getRotationMatrix2D(center, angle, 1.0)
    return cv2.warpAffine(frame, rotation_matrix, (w, h))

def capture_stream(index, url):
    """Capture frames from an RTSP stream."""
    global frames, running
    cap = cv2.VideoCapture(url)
    if not cap.isOpened():
        print(f"Error opening stream {index + 1}")
        return

    while running:
        ret, frame = cap.read()
        if ret:
            frame = cv2.resize(frame, (TARGET_WIDTH, TARGET_HEIGHT))
            #if index == 5:  # Rotate the first stream
            #    frame = rotate_frame(frame, angle=90)
            frame = add_border(frame, BORDER_SIZE, BORDER_COLOR)
            with locks[index]:
                frames[index] = frame
        else:
            print(f"Error reading frame from camera {index + 1}")
            black_frame = np.zeros((TARGET_HEIGHT, TARGET_WIDTH, 3), dtype=np.uint8)
            black_frame = add_border(black_frame, BORDER_SIZE, BORDER_COLOR)
            with locks[index]:
                frames[index] = black_frame
        time.sleep(0.03)  # Reduce CPU usage

    cap.release()

# Start a thread for each stream
threads = []
for i, url in enumerate(rtsp_urls):
    thread = threading.Thread(target=capture_stream, args=(i, url))
    thread.start()
    threads.append(thread)

# Create a window
window_name = "CCTV Monitoring - 4 Channels"
cv2.namedWindow(window_name, cv2.WINDOW_NORMAL)
cv2.resizeWindow(window_name, 1280, 720)

try:
    while True:
        # Combine frames into grid
        combined_frame = None
        with locks[0], locks[1], locks[2], locks[3]:
            if all(f is not None for f in frames):
                top_row = np.hstack((frames[0], frames[1]))
                bottom_row = np.hstack((frames[2], frames[3]))
                combined_frame = np.vstack((top_row, bottom_row))

        if combined_frame is not None:
            cv2.imshow(window_name, combined_frame)

        # Break the loop on 'q' key press
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

except KeyboardInterrupt:
    print("Exiting...")

# Cleanup
running = False
for thread in threads:
    thread.join()
cv2.destroyAllWindows()
