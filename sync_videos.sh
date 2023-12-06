timer=${1:-20}
count=0
good=1
dest="/opt/cam_proj/video"

se=$(date +"%s")

while [ 1 ]
do
	lf=$(find $dest -type f -exec ls -t1 {} + | head -1)
	le=$(date -r $lf +"%s")
	ce=$(date +"%s")
	diff=$(($ce - $le))

	if [ $diff -lt 100 ]
	then
		echo "Copying videos to GDrive..."
		/usr/bin/flock -n /tmp/sync.lock -c "rclone copy --max-age 4h /opt/cam_proj/video/ GoogleDrive:/CCTV"
		exit 0
	fi

	sleep $timer
	ce=$(date +"%s")
	count=$(($ce - $se))

	# Let the next cron job begin
	if [ $count -gt 110 ]; then
		echo "Copying videos to GDrive...(if any)"
		/usr/bin/flock -n /tmp/sync.lock -c "rclone copy --max-age 4h /opt/cam_proj/video/ GoogleDrive:/CCTV"
		exit 0;
	fi
done
