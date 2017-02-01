#!/usr/bin/env bash

if [ ! -x "$ANDROID_HOME" ];then
    echo "No found ANDROID_HOME"
    exit 1
fi

AVD_NAME=`$ANDROID_HOME/tools/android list avd | grep Name`
echo "AVD list:"
echo $AVD_NAME
AVD_NAME=($AVD_NAME)

if [ -x ${AVD_NAME[1]} ];then
    echo "No avd found."
    exit 1
fi

AVD_SELECT=${AVD_NAME[3]}
if [ -x ${AVD_NAME[3]} ];then
    AVD_SELECT=${AVD_NAME[1]}
fi

echo "Open $AVD_SELECT"

$ANDROID_HOME/tools/emulator -netdelay none -netspeed full -avd ${AVD_SELECT}
