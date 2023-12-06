timer=${1:-10}
count=0
good=1

se=$(date +"%s")

while [ 1 ]
do
	le=$(date -r /tmp/cctv/$(ls /tmp/cctv -rt | tail -1) +"%s")
	ce=$(date +"%s")
	diff=$(($ce - $le))
	lf=$(find /opt/cam_proj/video -type f -exec ls -t1 {} + | head -1)

	if [ $diff -gt 10 ]
	then
		le=$(date -r $lf +"%s")
		ce=$(date +"%s")
		diff=$(($ce - $le))
	fi

	echo "Last update $diff seconds ago"

	if [ $diff -gt 20 ]
	then
		curl -s https://cronitor.link/p/2d52d2a701564a4e983f6c6b56c71b13/dd-front-door?state=fail\&msg="Last update $diff seconds ago!"
		good=0
	fi

	sleep $timer
	ce=$(date +"%s")
	count=$(($ce - $se))

	if [ $count -gt 55 ]; then 
		if [ $good -eq 1 ] ; then
			curl -s https://cronitor.link/p/2d52d2a701564a4e983f6c6b56c71b13/dd-front-door?state=complete\&msg="Last update $diff seconds ago!"
		fi
		exit 0;
	fi
done
