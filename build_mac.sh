#!/bin/bash


set -e




if [ "$BUILD_OSX" != "yes" ]; then 
   exit 0
fi


USER_WEBRTC_URL="https://github.com/notedit/webrtc-clone.git"
git clone $USER_WEBRTC_URL src
# disable tests file download
sed -i -e "s|'src/resources'],|'src/resources'],'condition':'rtc_include_tests==true',|" src/DEPS
gclient config --unmanaged --name=src $USER_WEBRTC_URL
gclient sync 





MAC_OUT_DIR="$SRC_DIR/mac_libs"
MAC_PYTHON_ARGS="--output-dir $MAC_OUT_DIR --arch x64 --extra-gn-args rtc_include_tests=false rtc_build_tools=false rtc_build_examples=false rtc_enable_protobuf=false"


mkdir $MAC_OUT_DIR

mkdir $SRC_DIR/release


cp $ROOT_DIR/*.py $SRC_DIR/tools_webrtc/ios/


cd $SRC_DIR

# build mac 
python tools_webrtc/ios/build_mac_libs.py $MAC_PYTHON_ARGS

tar -zcvf $SRC_DIR/release/WebRTC.framework.tar.gz   ./mac_libs/WebRTC.framework



 if [ "$RELEASE_OSX" == "yes" ]; then 
    git clone https://github.com/notedit/webrtc-build-release.git
    cp $SRC_DIR/release/WebRTC.framework.tar.gz  ./webrtc-build-release/osx/
    cd ./webrtc-build-release
    git lfs track osx/WebRTC.framework.tar.gz
    git add osx/WebRTC.framework.tar.gz
    git add .gitattributes
    git commit -a -m "release osx"
    git remote set-url origin https://${GH_TOKEN}@github.com/notedit/webrtc-build-release.git > /dev/null 2>&1
    git remote -v
    git push https://${GH_TOKEN}@github.com/notedit/webrtc-build-release.git master > /dev/null 2>&1
 fi











