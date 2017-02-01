#!/bin/bash

# 1. create empty project.
git clone https://git.oschina.net/duino/HelloAndroid.git
cd HelloAndroid
mv .gitignore ..
git reset --hard 2b5ba
rm app/.gitignore
rm .git -rf
mv ../.gitignore .

git init
git add .
git commit -m "android hello world"

# Build and install
#./gradlew installDebug



## Deploy
#adb push /home/duino/project/AndroidStudioProjects/Test/app/build/outputs/apk/app-debug.apk /data/local/tmp/com.example.duino.test
#adb shell pm install -r "/data/local/tmp/com.example.duino.test"
## Run
#adb shell am start -n "com.example.duino.test/com.example.duino.test.MainActivity" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER
