/usr/bin/rclone delete --drive-use-trash=false GoogleDrive:CCTV/ --min-age=30d
/usr/bin/rclone rclone delete GoogleDrive:CCTV/ --drive-trashed-only --drive-use-trash=false

