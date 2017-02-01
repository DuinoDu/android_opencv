#!/bin/sh

# Edit   app/build.gradle
# Create app/src/main/cpp/CMakeLists.txt
# Create app/src/main/cpp/demo.cpp

if [ ! -x "$1" ];then
    echo "Usage: ./configNDK.sh HelloAndroid"
    exit 1
fi
cd $1

if [ ! -n "$ANDROID_NDK_HOME" ];then
    echo "No ANDROID_NDK_HOME"
    exit 1
fi

OPENCV_ANDROID_SDK=/home/duino/src/opencv/opencv_android/install/sdk
if [ ! -d $OPENCV_ANDROID_SDK ];then
    echo "No found opencv_android."
    echo "Refer to http://blog.csdn.net/DuinoDu/article/details/54710771 to build opencv for opencv."
    exit 1
fi


# 1. app/build.gradle, add two ndk staff
keySearch1="testInstrumentationRunner"
ndkStaff1="        ndk {\n            abiFilters 'armeabi-v7a', 'x86_64'\n        }\n        externalNativeBuild {\n            cmake {\n                arguments '-DANDROID_PLATFORM=android-22',\n                          '-DANDROID_TOOLCHAIN=gcc',\n                          '-DANDROID_STL=gnustl_static'\n            }\n        }"
keySearch2="buildToolsVersion"
ndkStaff2="    externalNativeBuild {\n        cmake { path \"src/main/cpp/CMakeLists.txt\" }\n    }"
sed -i -e "/${keySearch1}/a\\${ndkStaff1}" app/build.gradle
sed -i -e "/${keySearch2}/a\\${ndkStaff2}" app/build.gradle


# 2. create cpp files
mkdir -p app/src/main/cpp 
touch app/src/main/cpp/CMakeLists.txt
touch app/src/main/cpp/demo.cpp

echo "\
cmake_minimum_required(VERSION 3.4.1)

set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} -std=c++11 -Wall -Werror -frtti -fexceptions\")

set(OpenCV_DIR \"${OPENCV_ANDROID_SDK}/native/jni\")
find_package(OpenCV REQUIRED)

add_library(cv-jni SHARED
            demo.cpp)

target_link_libraries(cv-jni
                      android
                      log
                      \${OpenCV_LIBS})
" > app/src/main/cpp/CMakeLists.txt


echo "\
#include <jni.h>
#include <string>

#include <opencv2/opencv.hpp>

using namespace cv;

extern \"C\"
jstring Java_com_example_duino_hello_MainActivity_stringFromJNI( JNIEnv *env, jobject thiz)
{

    std::string hello = cv::String(\"Hello, opencv.\");
    return env->NewStringUTF(hello.c_str());
}


extern \"C\"
void Java_com_example_duino_hello_MainActivity_processFrame( JNIEnv *env, jobject thiz, jlong matPtr)
{
    Mat& image = *(Mat*)matPtr;
    rectangle(image, Rect(200,200,800,800), Scalar(0,255,0), 6);
    return;
}
" > app/src/main/cpp/demo.cpp

echo "\
    public Mat onCameraFrame(CvCameraViewFrame inputFrame) {
        frame = inputFrame.rgba();
        processFrame(frame.getNativeObjAddr());
        return frame;
    }

    public native String stringFromJNI();
    public native void processFrame(long matAddr);
    static { System.loadLibrary(\"cv-jni\");}
" >> app/src/main/java/com/example/duino/hello/MainActivity.java

echo "1. Add ndk staff to app/build.gradle...Done!"
echo "2. Create CMakeLists.txt...Done!"
echo "3. Create demo.cpp...Done!"
echo "\nYou may need to edit MainActivity.java."
