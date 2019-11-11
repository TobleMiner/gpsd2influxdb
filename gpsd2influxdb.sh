#!/usr/bin/env bash

set -e -o pipefail

INFLUX_URI="http://127.0.0.1:8086"
INFLUX_DB=gpsd
UPDATE_INTERVAL=10

jq_get_param() {
	local val="$(jq "$1")"
	if [ "$val" != null ]; then
		echo "$val"
	fi
}

gpsd_hostname="$(hostname)"
last_update=0
gpspipe -w | while read -r line; do
	class="$(jq_get_param ".class" <<< "$line")"
	if [ "$class" != '"TPV"' ]; then
		continue;
	fi

	now="$(date +%s)"
	if [ "$last_update" -gt "$((now - UPDATE_INTERVAL))" ]; then
		continue;
	fi
	gpsd_device="$(jq_get_param .device <<< $line)"

	last_update="$now"
	params="alt climb epc eps ept epv epx epy lat lon mode speed track"
	post_body=''
	for param in $params; do
		val="$(jq_get_param ."$param" <<< $line)"
		if [ -n "$val" ]; then
			post_body="$post_body"$'\n'"gpsd,host=$gpsd_hostname,device=$gpsd_device,tpv=alt value=$val"
		fi
	done

	curl -s -S -XPOST "$INFLUX_URI/write?db=$INFLUX_DB" --data-binary "$post_body" > /dev/null
done
