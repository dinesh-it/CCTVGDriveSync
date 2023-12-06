tmp_dir="/tmp/cctv"
dest="/opt/cam_proj/video"
rec_time=900
rtsp="rtsp://username:password@192.168.0.102:554/stream1"
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
	# Run ffmpeg if its not running before
	/usr/bin/flock -n /tmp/recorder.lock -c \
		"/usr/bin/ffmpeg -hide_banner -y \
		-loglevel error -rtsp_transport tcp \
		-use_wallclock_as_timestamps 1 -i $rtsp \
		-vcodec copy -acodec copy \
		-f segment -reset_timestamps 1 \
		-segment_time $rec_time -segment_format mkv \
		-segment_atclocktime 1 -strftime 1 $tmp_dir/%Y-%m-%d_%H:%M:%S.mkv"
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

	sleep 5

	if compgen -G "$tmp_dir/*.mkv" > /dev/null; then
		di=$(get_last_mtime)
    		if [ $di -gt 10 ]; then
	    		echo "Seems like files not getting updated, stopping with exit 1 and removing locks"
			curl -s https://cronitor.link/p/2d52d2a701564a4e983f6c6b56c71b13/dd-front-door?msg='Failed!'
			rm /tmp/recorder.lock
	    		exit 1
    		fi

		date=$(date +'%Y-%m-%d');
		out_path="$dest/$date/"
		mkdir -p $out_path
		find /tmp/cctv/ -type f -not -newermt '-10 seconds' -exec mv '{}' $out_path \;
	fi
done

