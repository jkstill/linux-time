#!/usr/bin/env bash

# get the difference in time between 2 servers;

# set on the command linke like this
# debug=1 get-time-diff.sh servername
declare debug
[[ -z $debug ]] && { debug=0; }

declare sshTarget=$1
[[ -z $sshTarget ]] && {
	echo 
	echo Usage: $0 target-server
	echo
	exit 1
}

declare dateCmd="date '+%s.%N'"
[[ $debug -eq 1 ]] && {
	echo dateCmd: $dateCmd
}

# first get the average runtime to run the date command locally
export TIME_AVG_ONLY=yes # get only the time diff from get-time-diff.sh
declare iterations=10

declare myHost=$(hostname)

: << 'SSH-OVERHEAD'

The SSH overhead code is unnecessary if the time is checked first on the remote server

Then the local time is retrieved immediately after that, and the only adjustment required
	is for the local runtime of the 'date' command.

[[ $debug -eq 1 ]] && {
	echo "getting ssh overhead"
}
declare avgSSHOverhead=$(time-command-avg.sh $iterations "ssh $sshTarget echo")
SSH-OVERHEAD

[[ $debug -eq 1 ]] && {
	echo "getting local average command time"
}
declare avgRunTime=$(time-command-avg.sh $iterations $dateCmd)

[[ $debug -eq 1 ]] && {
	#echo "avgSSHOverhead: $avgSSHOverhead"
	echo "    avgRunTime: $avgRunTime"
}

# do you know how this works?
# neither do I.  dc is not something I use frequently
# dc was used so the fractional seconds could be captured in the addition
# man dc
#declare overhead=$( echo "9 k $avgRunTime $avgSSHOverhead + p" | dc)
declare overhead=$avgRunTime

[[ $debug -eq 1 ]] && {
	echo "      overhead: $overhead"
}

[[ $debug -eq 1 ]] && {

cat <<EOF
  negative gap: the local server is ahead of the remote server
  positive gap: the local server is behind the remote server
      this is not necessarily 100% true due to changes in overhead
EOF

}

declare t1=$(ssh $sshTarget $dateCmd)
declare t2=$(eval $dateCmd)
[[ $debug -eq 1 ]] && {
	echo "            t1: $t1"
	echo "            t2: $t2"
}

echo "$t1 - $t2 - $overhead" | bc


