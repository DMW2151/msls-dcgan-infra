#! /bin/sh

# Init a Grafana Instance running in Docker; Exposed to the VPC

sudo apt-get update -y &&\
    sudo apt-get install -y docker docker.io

# Mount instance to EFS && Allow Sagemaker to use it for training local...
sudo mkdir -p /efs &&\
    sudo chmod 777 /efs

sudo mount -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${nfs_mount_ip}:/ /efs

# Run TensorBoard
docker run -ti \
    --name tensorboard \
    -v /efs/trained_model:/tf_logs \
    -p 0.0.0.0:6006:6006 \
    tensorflow/tensorflow:latest /bin/bash -c "tensorboard --logdir tf_logs/"


# Run Grafana on Start - This version 7.0.0 is the first on Ubuntu LTS 20.04
# should be similar to prior or subsequent versions, but solid and **stable**!
#
# On Startup: https://community.grafana.com/t/data-source-on-startup/8618
#

sudo mkdir -p /home/ubuntu/provisioning

sudo docker run -d \
    -p 3000:3000 \
    --name grafana \
    -v grafana_data:/var/lib/grafana \
    -v /home/ubuntu/provisioning:/etc/grafana/provisioning \
    grafana/grafana:7.0.0