#!/usr/bin/env bash

# convert total minutes to hours:minutes

declare totalMinutes=$1

: ${totalMinutes:=15}

declare runMinutes runHours

(( runHours = ( totalMinutes - (totalMinutes%60))/60 ))
(( runMinutes = totalMinutes%60 ))

# may only work up to 23:59 hours depending on format expected by application
declare runTime
runTime=$(printf "%02d:%02d" $runHours $runMinutes)

echo runHours: $runHours
echo runMinutes: $runMinutes
echo runTime: $runTime

