#!/usr/bin/env bash

# This script is intended as an initialization script used in azuredeploy.json
# See documentation here: https://docs.microsoft.com/en-us/azure/virtual-machines/extensions/custom-script-linux#template-deployment

# see abbreviated notes in README.md
# comments below:

adminUser=$1

WD=/home/$adminUser/

echo WD is $WD

if [ ! -d $WD ]; then
    echo $WD does not exist - aborting!!
    exit
else
    cd $WD
    echo "Working in $(pwd)"
fi

# Fix a broken repository
sudo cp /etc/apt/sources.list.d/tensorflow-serving.list /etc/apt/sources.list.d/tensorflow-serving.list.save
sudo rm /etc/apt/sources.list.d/tensorflow-serving.list

# Update repos
sudo apt update

# Install OpenCV
sudo apt-get install python-opencv

# Clone darknet
git clone https://github.com/AlexeyAB/darknet.git
cd darknet/

# Update variables to enable GPU acceleration for build
sed -i "s/GPU=0/GPU=1/g" Makefile
sed -i "s/CUDNN=0/CUDNN=1/g" Makefile
sed -i "s/CUDNN_HALF=0/CUDNN_HALF=1/g" Makefile
sed -i "s/OPENCV=0/OPENCV=1/g" Makefile
sed -i "s/AVX=0/AVX=1/g" Makefile
sed -i "s/OPENMP=0/OPENMP=1/g" Makefile
sed -i "s/LIBSO=0/LIBSO=1/g" Makefile
sed -i "s/NVCC=nvcc/NVCC=\/usr\/local\/cuda-10.0\/bin\/nvcc/g" Makefile

# Change permissions on shell scripts
sudo chmod ugo+x *.sh

export PATH=/usr/local/cuda-10.0/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=/usr/local/cuda-10.0/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}

# Build darknet
sudo make

echo "Done!"