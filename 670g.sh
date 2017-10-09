#! /bin/bash
# Initialising Carelink Automation
# Proof of concept ONLY - 640g csv to NightScout
#
echo Setting Variables... > /root/670g.log
source chip_config.sh

# Capture empty JSON files later ie "[]"
EMPTYSIZE=3 #bytes
# ****************************************************************************************
# Let's go...
# ****************************************************************************************

# Uploader setup
START_TIME=0	#last time we ran the uploader (if at all)

# Check if we're probably running as cron job
uptime1=$(</proc/uptime)
uptime1=${uptime%%.*}

# Allow to run for ~240 hours (roughly), ~5 min intervals
# This thing is bound to need some TLC and don't want it running indefinitely...

cd /root/decoding-contour-next-link

python read_minimed_next24.py
sleep 10
python read_minimed_next24.py
	
# Time to extract and upload entries (SG only)
filesize=0
if [ -s latest_sg.json ] 
then 
	filesize=$(stat -c%s latest_sg.json)
fi
if [ $filesize -gt $EMPTYSIZE ]
then
	sed -i '1s/^/[{/' latest_sg.json
	echo '}]' >> latest_sg.json
	more latest_sg.json
	curl -s -X POST --header "Content-Type: application/json" --header "Accept: application/json" --header "api-secret:"$api_secret_hash --data-binary @latest_sg.json "$your_nightscout"$"/api/v1/entries"
fi

# And now basal info
# filesize=$(wc -c <latest_basal.json)
filesize=0
if [ -s latest_basal.json ]
then
	filesize=$(stat -c%s latest_basal.json)
fi
if [ $filesize -gt $EMPTYSIZE ]
then
	sed -i '1s/^/[{/' latest_basal.json
	echo '}]' >> latest_basal.json
	more latest_basal.json
	curl -s -X POST --header "Content-Type: application/json" --header "Accept: application/json" --header "api-secret:"$api_secret_hash --data-binary @latest_basal.json "$your_nightscout"$"/api/v1/treatments"
fi

echo  > /root/670g.log
echo "Checking for Bayer..."  > /root/670g.log
lsusb > /root/lsusb.log
grep 'Bayer' /root/lsusb.log > /root/usb.log
# Bayer will be listed -  "Bayer Health Care LLC"
# Action (if required): reboot (ffs, got to be a better way :o )
if [ ! -s /root/usb.log  ] 
then 
	echo 'Announcement - USB Loss'  > /root/670g.log
	echo '{"enteredBy": "robopanc-ed-209", "eventType": "Announcement", "reason": "", "notes": "Cycle Bayer Power", "created_at": "'$(date +"%Y-%m-%dT%H:%M:%S.000%z")$'", " isAnnouncement": true }' > announcement.json
	curl -s -X POST --header "Content-Type: application/json" --header "Accept: application/json" --header "api-secret:"$api_secret_hash --data-binary @announcement.json "$your_nightscout"$"/api/v1/treatments"
#/sbin/shutdown -r +1
fi


###################
#read fuel gauge B9h
cd /root/robopanc-ed-209
openaps battery-status

################################
# Power Action
cd /root/robopanc-ed-209 && openaps battery-status && cat /root/robopanc-ed-209/monitor/edison-battery.json | json batteryVoltage | awk '{if ($1<=3050)system("sudo shutdown -h now")}'

rm -f latest_sg.json
rm -f latest_basal.json
