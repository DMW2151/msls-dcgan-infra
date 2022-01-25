#! /bin/bash

# Assume we're running on the AWS Deep-Learning AMI on Ubuntu-18.04, the underlying instance 
# type should change between (p3.2xlarge, dl1.24xlarge)

# Install Apt Utils for Instance
sudo apt-get install -y \
    iotop \
    tmux \
    jq \
    nfs-common \
    collectd \

# Expect these to already be Available in the AMI's `pytorch_p38` environment,
# but install them to the host's default environment too...
sudo pip install \
    nvidia-ml-py \
    boto3 \
    pynvml

# Install Cloudwatch Agent - Assume not there Already
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

# Mount Elastic Filesystem
sudo mkdir -p /efs &&\
    sudo chmod 777 /efs

sudo mount -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${nfs_mount_ip}:/ /efs

# Squeezing a little performance - Increase the NFS Read-Ahead 
# See: https://docs.aws.amazon.com/efs/latest/ug/performance-tips.html
sudo bash -c "echo 15000 > /sys/class/bdi/0:$(stat -c '%d' efs)/read_ahead_kb"