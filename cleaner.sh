echo "Cleaner script started"

# Check for temp videos files that are incomplete and move it to incomplete
echo "Cleaning incomplete files from /tmp/cctv..."
find /tmp/cctv/ -type f -mmin +1 -exec mv '{}' /opt/cam_proj/video/incomplete/ \;

# Check for older files and delete it to save space on disk
echo "Cleaning older files to free up space..."
find /opt/cam_proj/video/ -type f -mmin +300 -name '*.*' -execdir rm -- '{}' \;

# Remove empty directories
echo "Cleaning empty directories..."
rmdir --ignore-fail-on-non-empty /opt/cam_proj/video/* >/dev/null

echo "Copying current /tmp/cctv version to drive..."
min=$(date +"%Y%m%d-%H%M%S")
mkdir -p /tmp/tcctv/$min
cp /tmp/cctv/*.mkv /tmp/tcctv/$min/
#rclone delete --drive-use-trash=false GoogleDrive:/CCTV/tmp/
rclone sync --drive-use-trash=false --ignore-size --ignore-checksum /tmp/tcctv/ GoogleDrive:/CCTV/tmp/
rm -rf /tmp/tcctv/*

echo "Cleaner script completed"
