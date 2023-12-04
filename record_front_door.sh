tmp_dir="/tmp/cctv"
dest="/opt/cam_proj/video/"
rec_time=600
echo "Starting CCTV record script"
mkdir -p $tmp_dir

get_last_mtime() {
	lf=$(ls /tmp/cctv -rt | tail -1)
	le=$(date -r /tmp/cctv/$lf +"%s")
	ce=$(date +"%s")
	diff=$(($ce - $le))
	echo "$diff"
}

record_video() {

	file=$(date +'%Y-%m-%d_%H:%M:%S.mkv');
	date=$(date +'%Y-%m-%d');
	t="$dest$date";
	mkdir -p $t;

	# Run ffmpeg if its not running before
	/usr/bin/flock -n /tmp/recorder.lock -c \
		"echo 'New file: $tmp_dir/$file';
		/usr/bin/ffmpeg -hide_banner -y -loglevel error -rtsp_transport tcp \
		-i 'rtsp://username:password@192.168.0.102:554/stream1' \
		-vcodec copy -c:a copy \
		-f segment -ss 0 -t $rec_time -segment_time $rec_time \
		-strftime 1 \
		$tmp_dir/$file" \
		&& echo "Copying file to $t" \
		&& mv $tmp_dir/$file $t \
		&& record_video
}

if compgen -G "$tmp_dir/*.mkv" > /dev/null; then
    echo "Some mkv files already exist"
    di=$(get_last_mtime)
    echo "Last update was $di seconds ago"
    
    if [ "$di" -lt 10 ]; then
	    echo "Other process seems to be recording, exiting with 0..."
	    exit 0
    fi
fi

# Remove lock and execute
rm /tmp/recorder.lock
pkill -f 'ffmpeg'

while [ 1 ]
do
	record_video &
	/opt/cam_proj/sync_videos.sh &
	sleep 5

	if compgen -G "$tmp_dir/*.mkv" > /dev/null; then
		di=$(get_last_mtime)
    		if [ $di -gt 10 ]; then
	    		echo "Seems like files not getting updated, stopping with exit 1 and removing locks"
			curl -s https://cronitor.link/p/2d52d2a701564a4e983f6c6b56c71b13/dd-front-door?msg='Failed!'
			rm /tmp/recorder.lock
	    		exit 1
    		fi
	fi
done


