/usr/bin/flock -n /tmp/sync.lock -c "rclone copy --max-age 4h /opt/cam_proj/video/ GoogleDrive:/CCTV"
