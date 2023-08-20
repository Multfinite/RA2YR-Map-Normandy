#!/bin/bash

echo ${PWD}

INIMerger=`cat settings.json | jq --raw-output '.INIMerger'`
BriefingGen=`cat settings.json | jq --raw-output '.BriefingGen'`
Gamemodes=`cat settings.json | jq --raw-output '.Gamemodes'`
Output=`cat settings.json | jq --raw-output '.Output'`
Patches=`cat settings.json | jq --raw-output '.Patches'`
MissionTester=`cat settings.json | jq --raw-output '.MissionTester'`

SourceFile=`cat version | jq --raw-output '.source'`
NamePattern=`cat version | jq --raw-output '.name'`
OutputFilePattern=`cat version | jq --raw-output '.filename'`
Version=`cat version | jq --raw-output '.version'`
Naming=`cat version | jq --raw-output '.naming'`

echo "INIMerger is $INIMerger"
echo "BriefingGen is BriefingGen"
echo "Gamemodes are $Gamemodes"
echo "Output is $Output"
echo "Patches are $Patches"
echo "Source File: $SourceFile"
echo "Name Pattern: $NamePattern"
echo "Output File Pattern: $OutputFilePattern"
echo "Map Version: $Version"
echo "Naming: $Naming"
echo "Mission Tester by @athse: $MissionTester"

`mkdir -p $Output`

 cr=$'\r'
 lf=$'\n'

 echo "====Run mistest on clean map===="
 cmd="tclsh \"$MissionTester\" \"$SourceFile\""
 echo "($cmd)"
 eval $cmd
 echo "========================"

jq -c -r '.gamemodes[]' version | while read Gamemode; do
	echo "=================="
	Gamemode=${Gamemode%$cr}
	Gamemode=${Gamemode%$lf}
	echo "${Gamemode}"
	OutputFile="${OutputFilePattern}"
	OutputFile="${OutputFile/__VERSION__/"${Version}"}"
	OutputFile="${OutputFile/__GAMEMODE__/"${Gamemode}"}"
	OutputFile="${Output}/${OutputFile}"
	echo "Output File: $OutputFile"

	MapName="${NamePattern/__VERSION__/"${Version}"}"
	echo "Map Name: $MapName"

	GamemodeFile="$Gamemodes/$Gamemode"."ini"
	echo "Gamemode File: $GamemodeFile"

	cmd="\"${INIMerger}\" -tron \"${OutputFile}\" \"${SourceFile}\" \"${GamemodeFile}\""
	echo "($cmd)"
	eval $cmd

	echo "[Basic]" >> "map_name.ini"
	echo $"Name=${MapName}" >> "map_name.ini"
	cmd="\"${INIMerger}\" \"${OutputFile}\" \"${OutputFile}\" map_name.ini"
	eval $cmd
	rm "map_name.ini"
	
	cmd="\"${BriefingGen}\" \"${OutputFile}\" \"${OutputFile}\" \"${Patches}/briefings.ini\" \"${Naming}\""
	echo "($cmd)"
	eval $cmd
done

echo "=======DONE======="