#!/bin/bash

if [ ! -x "$1" ];then
    echo "Please select a project dir."
    exit 1
fi
cd $1

# 1. add MainActivity.java, activity_main.xml, AndroidManifest.xml
git clone http://git.oschina.net/duino/18v9bg0jt4lqfi62epxya91.code.git
mv 18v9bg0jt4lqfi62epxya91.code/activity_main.xml app/src/main/res/layout/
rm 18v9bg0jt4lqfi62epxya91.code -rf

java_src=`find app/src/main/java -name "*.java"`
git clone http://git.oschina.net/duino/0zls1b67geqahjunvw34d11.code.git
mv 0zls1b67geqahjunvw34d11.code/MainActivity.java $java_src
rm 0zls1b67geqahjunvw34d11.code -rf

git clone http://git.oschina.net/duino/acmxbig9e5j7hyfwp4v6t11.code.git
mv acmxbig9e5j7hyfwp4v6t11.code/AndroidManifest.xml app/src/main/AndroidManifest.xml
rm acmxbig9e5j7hyfwp4v6t11.code -rf

###############################
# Add opencv_java_wrapper lib #
###############################

# 2.1 add opencv java sub project
OPENCV_ANDROID_SDK=/home/duino/src/opencv/opencv_android/install/sdk
if [ ! -d $OPENCV_ANDROID_SDK ];then
    echo "No found opencv_android."
    echo "Refer to http://blog.csdn.net/DuinoDu/article/details/54710771 to build opencv for opencv."
    exit 1
fi
if [ ! -d opencv ];then
    mkdir opencv
fi
cp $OPENCV_ANDROID_SDK/java/* opencv/ -r


# 2.2 edit opencv/build.gradle
touch opencv/build.gradle
echo "\
apply plugin: 'com.android.library'
buildscript {
    repositories {
        jcenter()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:2.2.3'
   }
}
android {
    compileSdkVersion 25
    buildToolsVersion \"25.0.2\"
    defaultConfig {
        minSdkVersion 14
        targetSdkVersion 22
        versionCode 310
        versionName \"310\"
    }
    sourceSets{
        main{
            manifest.srcFile \"AndroidManifest.xml\"
            java.srcDirs = ['src']
            resources.srcDirs = ['src']
            res.srcDirs = ['res']
            aidl.srcDirs = ['src']
        }
    }
    lintOptions {
        abortOnError false
    }
}" > opencv/build.gradle


# 2.3 add camera support in opencv/AndroidManifest.xml
filename='opencv/AndroidManifest.xml'
echo "\
<?xml version=\"1.0\" encoding=\"utf-8\"?>
<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\"
      package=\"org.opencv\"
      android:versionCode=\"3100\"
      android:versionName=\"3.1.0-dev\">

    <uses-permission android:name=\"android.permission.CAMERA\"/>
    <uses-feature android:name=\"android.hardware.camera\"/>
    <uses-feature android:name=\"android.hardware.camera.autofocus\"/>
    <uses-feature android:name=\"android.hardware.camera.front\"/>
    <uses-feature android:name=\"android.hardware.camera.front.autofocus\"/>
</manifest>" > $filename


# 2.4 edit app/build.gradle
filename='app/build.gradle'
lines_num=`wc -l $filename | grep -Eo '[0-9]+'`
pos=$[$lines_num-1]
sed -i "$pos i compile project(':opencv')" $filename


# 2.5. edit settings.gradle
echo "include ':opencv'" >> settings.gradle


# 3. copy jniLibs, for static lib
if [ ! -d app/src/main/jniLibs ];then
    mkdir app/src/main/jniLibs
    cp $OPENCV_ANDROID_SDK/native/libs/* app/src/main/jniLibs/ -r
fi


git add .
git commit -m "add opencv java warp project"


# Build and install
./gradlew installDebug


## Deploy
#adb push /home/duino/project/AndroidStudioProjects/Test/app/build/outputs/apk/app-debug.apk /data/local/tmp/com.example.duino.test
#adb shell pm install -r "/data/local/tmp/com.example.duino.test"
## Run
#adb shell am start -n "com.example.duino.test/com.example.duino.test.MainActivity" -a android.intent.action.MAIN -c android.intent.category.LAUNCHER
