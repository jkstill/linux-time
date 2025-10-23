#!/usr/bin/env bash

#TIMESTAMP=$(date +%Y_%m_%d_%H_%M_%S)
TIMESTAMP=$(date +%Y-%m-%d_%H-%M-%S)
[[ -n "$1" ]] && echo "$TIMESTAMP"
