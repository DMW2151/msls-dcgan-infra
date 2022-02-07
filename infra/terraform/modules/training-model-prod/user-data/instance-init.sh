#! /bin/bash

# Assume we're running on the AWS Deep-Learning AMI on Ubuntu-18.04, the underlying instance 
# type should change between (p3.2xlarge, dl1.24xlarge)

# Install Apt Utils for Instance
sudo apt-get install -y \
    iotop \
    tmux \
    jq \
    git \
    atop \
    nfs-common \
    collectd \
    sysstat \
    lsblk 


# Expect these to already be Available in the AMI's `pytorch_p38` environment,
# but install them to the host's default environment too...
sudo pip install \
    nvidia-ml-py \
    python3-pip \
    boto3 \
    pynvml \
    tensorboard

# Install Cloudwatch Agent  && set to run on startup
curl -XGET https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb \
    --output amazon-cloudwatch-agent.deb && \
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Enable Cloudwatch Metrics - Assumes US-EAST-1
# TODO: Fix this hardcoded region! Terraform gets mad and expects region passed as an arg to the template
sudo mkdir -p /opt/aws/amazon-cloudwatch-agent/bin/ &&\
    sudo touch /opt/aws/amazon-cloudwatch-agent/bin/config.json &&\
    sudo chmod 777 /opt/aws/amazon-cloudwatch-agent/bin/config.json &&\
    echo `(aws ssm get-parameters --names cw_agent__config --region=us-east-1 | jq -r '.Parameters | first | .Value' | base64 -d)`  >> /opt/aws/amazon-cloudwatch-agent/bin/config.json

sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json

# Enable GPU Monitor and Set to Run on Startup
python3 ~/tools/GPUCloudWatchMonitor/gpumon.py &

# Create EFS + EBS MountPoint
sudo mkdir -p /data &&\
    sudo chmod 777 /data

sudo mkdir -p /efs &&\
    sudo chmod 777 /efs

# Mount Elastic Filesystem
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${nfs_mount_ip}:/ /efs

# Mount EBS -> Assumes Already Formatted; DO NOT FORMAT on Instance Up!
sudo mount -t ext4 /dev/xvdh /data

# OR Mount to other place...
sudo mkdir -p /ebs &&\
    sudo mount -t ext4 /dev/nvme1n1 /ebs  
 
# Clone Repo
cd /home/ubuntu && git clone https://github.com/DMW2151/msls-pytorch-dcgan.git
