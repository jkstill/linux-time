#!/usr/bin/env bash

# use strace to get the exact time required to run a command

declare cmd=$@

[[ -z $cmd ]] && {
	echo
	echo usage: $0 "command to run"
	echo
	exit 1
}

# test to see if cmd is executing
#strace  -ttt $cmd 

strace  -ttt $cmd 2>&1  | awk '{if (NR==1) b=$1}END{printf("%06.6f\n", $1-b) }'


