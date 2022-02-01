#! /bin/bash

# Initializes a Sagemaker notebook; allows us to test the model without shuffling
# data and images back and forth too much...

sudo yum install epel-release -y &&\
sudo yum update -y

sudo yum install -y \
    amazon-cloudwatch-agent \
    nfs-utils \
    htop \
    iotop 

sudo amazon-linux-extras install -y \
    collectd

# Enable GPU Monitor && Start in Background...
sudo pip3 install \
    nvidia-ml-py \
    boto3 \
    pynvml \
    theano 

# Install FFMPEG from Mirror
sudo mkdir -p /usr/local/bin/ffmpeg &&\
    cd /usr/local/bin/ffmpeg &&\
    sudo wget https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.2.1-amd64-static.tar.xz &&\
    sudo tar xvf ffmpeg-4.2.1-amd64-static.tar.xz &&\
    sudo mv ffmpeg-4.2.1-amd64-static/ffmpeg . &&\
    sudo ln -s /usr/local/bin/ffmpeg/ffmpeg /usr/bin/ffmpeg

# Mount instance to EFS && Allow Sagemaker to use it for training local...
sudo mkdir -p /efs &&\
    sudo chmod 777 /efs

sudo mount -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${nfs_mount_ip}:/ /efs

    
