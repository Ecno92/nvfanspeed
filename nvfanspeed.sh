#!/bin/bash
echo "Starting NvFanSpeed"

# Default GPU/FAN
gpu=0
fan=0

# Speed and temperature settings
speed_low=37
speed_mid=60
speed_max=100

temp_mid=45
temp_max=70

# Make sure to enable auto mode when the script is interrupted.
end() {
        nvidia-settings -a "[gpu:$gpu]/GPUFanControlState=0" > /dev/null
	echo "Fan settings are set back to automatic"
        exit 0
};

trap "end" INT

# Read the temperature once in a while and set the desired fan speed.
echo "Fan settings are controlled by script"
while true
do
    cur_temp="$(nvidia-smi -i $gpu --query-gpu=temperature.gpu --format=csv,noheader)"

    speed=$speed_low
    if (($cur_temp > $temp_mid))
    then
        speed=$speed_mid
    elif (($cur_temp > $temp_max))
    then
        speed=$speed_max
    fi

    echo "Current temperature=$cur_temp, Target speed=$speed"
    nvidia-settings -a "[gpu:$gpu]/GPUFanControlState=1" -a "[fan:$fan]/GPUTargetFanSpeed=$speed" > /dev/null

    sleep 10
done
