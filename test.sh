#!/bin/bash

echo ${PWD}

MissionTester=`cat settings.json | jq --raw-output '.MissionTester'`

SourceFile=`cat version | jq --raw-output '.source'`

echo "Source File: $SourceFile"
echo "Mission Tester by @athse: $MissionTester"

 echo "====Run mistest on clean map===="
 cmd="tclsh \"$MissionTester\" \"$SourceFile\""
 echo "($cmd)"
 eval $cmd
 echo "========================"