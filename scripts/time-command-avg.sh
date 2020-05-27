#!/usr/bin/env bash

# use strace to get the an average of the time required to run a command
# edit: no longer using strace as the overhead is too high

declare showAvgOnly=0

[[ -n $TIME_AVG_ONLY ]] && {
	showAvgOnly=1
}

vprint () {
	local msg="$@"
	if [[ $showAvgOnly -eq 0 ]];  then
		echo "$msg"
	fi
}

nprint () {
	local msg="$@"
	if [[ $showAvgOnly -ne 0 ]];  then
		echo "$msg"
	fi
}


declare iterations=$1; shift
declare cmd=$@

[ -z "$cmd" -o -z "$iterations" ] && {
	echo
	echo usage: $0 iterations "command to run"
	echo
	exit 1
}

# test to see if cmd is executing
#strace  -ttt $cmd 

declare -a atime

for i in $(seq 0 $( echo $iterations -1 | bc ) )
do
	# too much overhead using strace
	#declare etime=$(strace  -ttt $cmd 2>&1  | awk '{if (NR==1) b=$1}END{print $1-b }')
	declare etime=$(echo "$cmd" | perl -e 'use strict;
		use warnings;
		use Time::HiRes qw(tv_interval usleep gettimeofday);
		my $cmd = join(q/ /, <STDIN>);
		my $t0 = [gettimeofday];
		my $dummy = qx/ $cmd /;
		my $t1 = [gettimeofday];
		my $elapsed = tv_interval ( $t0, $t1);
		printf(qq{%0.9f\n},$elapsed);'
	)
	vprint "etime: $etime"
	atime[$i]=$etime
done

els=${#atime[*]}
(( els-- ))

eTotal=0
for i in $(seq 0 $els)
do
	#echo $i: ${atime[$i]}
	#eTotal=$( echo $eTotal + ${atime[$i]} | bc)
	eTotal=$( echo "9 k $eTotal ${atime[$i]} + p" | dc)
done

avg=$(echo "9 k $eTotal $iterations / p" | dc)

vprint "" 
vprint "               cmd: $cmd"
vprint "        iterations: $iterations"
vprint "total elapsed time: $eTotal"
vprint "      avg run time: $avg"
nprint "$avg"




