# android_opencv
Shell tools to play opencv on android.
# Requirement
1. Linux
2. Android sdk and ndk, set ANDROID_HOME, ANDROID_NDK_HOME
3. Opencv for android, set OPENCV_ANDROID_SDK. If you want to build it yourself, refer [here](http://blog.csdn.net/DuinoDu/article/details/54710771).

# Usage
```
git clone https://github.com/DuinoDu/android_opencv
cd android_opencv
chmod +x *.sh
./3_startAVD.sh
./0_create.sh
./1_configOpenCV.sh
./2_configNDK.sh
```
# Detail
**0_create.sh**  Create empty Android Studio project.

**1_configOpenCV.sh**  Add opencv java warp sub project.

**2_configNDK.sh**  Add opencv native code.

**3_startAVD.sh**  Start a android virtual device.
