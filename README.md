# CCTVGDriveSync

CCTVGDriveSync is a collection of shell scripts designed to facilitate the seamless synchronization of CCTV video footage with Google Drive using ffmpeg and rclone. This project ensures continuous recording, efficient storage management, and reliable cloud backup.

## Table of Contents
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage](#usage)
- [Scripts](#scripts)
  - [check_heartbeat.sh](#check_heartbeatsh)
  - [clean_drive.sh](#clean_drivesh)
  - [cleaner.sh](#cleanersh)
  - [record_front_door.sh](#record_front_doorsh)
  - [sync_videos.sh](#sync_videossh)

## Prerequisites

Make sure the following tools are installed on your system:
- `ffmpeg`
- `rclone`
- `curl`

## Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/CCTVGDriveSync.git
   cd CCTVGDriveSync
   ```

2. Make the scripts executable:

   ```bash
   chmod +x check_heartbeat.sh clean_drive.sh cleaner.sh record_front_door.sh sync_videos.sh
   ```

## Configuration

Ensure that your ffmpeg and rclone configurations are set up correctly. Update any necessary parameters in the scripts, such as RTSP stream details, file paths, and Google Drive paths. To configure you google drive account with rclone follow the steps in [rclone document](https://rclone.org/drive/).

## Usage

Configure the scripts as cron jobs to run every minute for continuous monitoring and synchronization.

```bash
* * * * * /path/to/CCTVGDriveSync/check_heartbeat.sh
* * * * * /path/to/CCTVGDriveSync/cleaner.sh
* * * * * /path/to/CCTVGDriveSync/record_front_door.sh
* * * * * /path/to/CCTVGDriveSync/sync_videos.sh
0 */10 * * * /path/to/CCTVGDriveSync/clean_drive.sh
```

## Scripts

### check_heartbeat.sh

This script monitors the last update time of CCTV footage and triggers alerts if no updates occur within a specified timeframe.

### clean_drive.sh

Deletes old files from the Google Drive directory to maintain storage efficiency.

### cleaner.sh

Cleans incomplete and older files from local storage, frees up disk space, and copies current footage to Google Drive.

### record_front_door.sh

Initiates continuous recording of the front door CCTV stream using ffmpeg and manages the synchronization process.

### sync_videos.sh

Ensures synchronized copying of recorded videos to Google Drive, preventing data loss.

