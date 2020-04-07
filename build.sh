#!/bin/bash
# Build script of XIVO software.
# Author: Xiaohan Fei (feixh@cs.ucla.edu)
# Basic usage: execute the script in terminal
# ./build.sh
# Options:
# 1) ros: build with ROS support
# 2) g2o: build with pose graph optimization from g2o library
# 3) gperf: use google performance profiling tools
# Example:
# ./build.sh ros g2o gperf

# parsing options
BUILD_ROSNODE=false
BUILD_G2O=false
USE_GPERFTOOLS=false

for arg in "$@"
do
  if [ $arg == "ros" ]; then
    BUILD_ROSNODE=true
  fi

  if [ $arg == "g2o" ]; then
    BUILD_G2O=true
  fi

  if [ $arg == "gperf" ]; then
    USE_GPERFTOOLS=true
  fi
done

if [ $BUILD_ROSNODE = true ]; then
  echo "BUILD WITH ROS SUPPORT"
fi

if [ $BUILD_G2O = true ]; then
  echo "BUILD WITH G2O SUPPORT"
fi

if [ $USE_GPERFTOOLS = true ]; then
  echo "USE GOOGLE PERFORMANCE TOOLS (GPERFTOOLS) FOR PROFILING"
fi


# build dependencies
PROJECT_DIR=$(pwd)
echo $PROJECT_DIR

cd $PROJECT_DIR/thirdparty/googletest
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=..
make install -j

cd $PROJECT_DIR/thirdparty/gflags
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=..
make install -j

cd $PROJECT_DIR/thirdparty/glog
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=..
make install -j

cd $PROJECT_DIR/thirdparty/eigen-3.3.7
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=..
make install -j

cd $PROJECT_DIR/thirdparty/Pangolin
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=..
make install -j

cd $PROJECT_DIR/thirdparty/jsoncpp
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=.. -DBUILD_SHARED_LIBS=TRUE
make install -j

# to build gperftools, need to install autoconf and libtool first
if [ $USE_GPERFTOOLS = true ]; then
  sudo apt-get install autoconf libtool
  cd $PROJECT_DIR/thirdparty/gperftools
  ./autogen.sh
  ./configure --prefix=$PROJECT_DIR/thirdparty/gperftools
  make install
fi

if [ $BUILD_G2O = true ]; then
  cd $PROJECT_DIR/thirdparty/g2o
  mkdir build
  cd build
  cmake .. -DCMAKE_INSTALL_PREFIX=../release -DEIGEN3_INCLUDE_DIR=../eigen-3.3.7
  make install -j
fi


# build xivo
mkdir ${PROJECT_DIR}/build
cd ${PROJECT_DIR}/build

cmake .. -DBUILD_G2O=$BUILD_G2O -DBUILD_ROSNODE=$BUILD_ROSNODE -DUSE_GPERFTOOLS=$USE_GPERFTOOLS -DPYTHON_EXECUTABLE=/usr/bin/python

make -j
