#! /bin/bash

# Initializes a Sagemaker notebook; allows us to test the model without shuffling
# data and images back and forth too much...

sudo yum install epel-release -y &&\
sudo yum update -y

sudo yum install -y \
    amazon-cloudwatch-agent \
    nfs-utils

sudo amazon-linux-extras install -y \
    collectd

# Cloudwatch Agent;
# TODO: Fix this hardcoded region! Terraform gets mad and expects region passed as an arg to the template
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/bin/ &&\
    sudo touch /opt/aws/amazon-cloudwatch-agent/bin/config.json &&\
    sudo chmod 777 /opt/aws/amazon-cloudwatch-agent/bin/config.json &&\
    echo `(aws ssm get-parameters --names cw_agent__config --region=us-east-1 | jq -r '.Parameters | first | .Value' | base64 -d)`  > /opt/aws/amazon-cloudwatch-agent/bin/config.json

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

# Mount instance to EFS && Allow Sagemaker to use it for training local...
sudo mkdir -p /efs &&\
    sudo chmod 777 /efs

sudo mount -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${nfs_mount_ip}:/ /efs

# Squeezing a little performance - Increase the NFS Read-Ahead 
# See: https://docs.aws.amazon.com/efs/latest/ug/performance-tips.html
sudo bash -c "echo 15000 > /sys/class/bdi/0:$(stat -c '%d' /efs)/read_ahead_kb"

# Enable GPU Monitor && Start in Background...
sudo pip3 install \
    nvidia-ml-py \
    boto3 \
    pynvml \
    theano 
    
sudo mkdir -p /home/ec2-user/tools/GPUMonitoring/ &&
    sudo curl -XGET https://s3.amazonaws.com/aws-bigdata-blog/artifacts/GPUMonitoring/gpumon.py > /home/ec2-user/tools/GPUMonitoring/gpumon.py &&\
    sudo python3 /home/ec2-user/tools/GPUCloudWatchMonitor/gpumon.py &

# Install FFMPEG from Mirror
sudo mkdir -p /usr/local/bin/ffmpeg &&\
    cd /usr/local/bin/ffmpeg &&\
    sudo wget https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.2.1-amd64-static.tar.xz &&\
    sudo tar xvf ffmpeg-4.2.1-amd64-static.tar.xz &&\
    sudo mv ffmpeg-4.2.1-amd64-static/ffmpeg . &&\
    sudo ln -s /usr/local/bin/ffmpeg/ffmpeg /usr/bin/ffmpeg

