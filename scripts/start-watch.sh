#!/usr/bin/env bash


# exit loop when lockfile cannot be read
# if the shared file is on a CIFS mount, it must be removed
# as the permissions cannot be changed from linux

lockfile=/mnt/shared//tmp/watchlock.lock

while [[ -r $lockfile ]]
do
        sleep 0.001
done

watch -n 5 'date +%Y-%m-%d_%H-%M-%S_%N'

