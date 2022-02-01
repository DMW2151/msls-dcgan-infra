#! /bin/sh

# Create an instance running Tensorboard and Grafana in containers; both exposed within the VPC
# include a few utils from apt
sudo apt-get update -y &&\
    sudo apt-get install -y \
    docker \
    docker.io \
    nfs-common

# Mount instance to EFS && allow tensorboard to see mid-training traces written by DL machines and
# Grafana to persist dashboards 
sudo mkdir -p /efs &&\
    sudo chmod 777 /efs

sudo mount -t nfs4 \
    -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${nfs_mount_ip}:/ /efs

# Run TensorBoard && include a (hack-ish) trick to avoid maintaining our own image
sudo docker run -d \
    -p 6006:6006 \
    --name tensorboard \
    --restart always \
    -v /efs/trained_model:/tf_logs:ro \
    tensorflow/tensorflow:latest /bin/bash -c "pip3 install -U tensorboard-plugin-profile torch_tb_profiler && tensorboard --bind_all --logdir /tf_logs/"


# Run Grafana - This version, 7.0.0, is the first on Ubuntu LTS 20.04 should be similar to prior or subsequent versions
# See Instructions on Startup: https://community.grafana.com/t/data-source-on-startup/8618

# Create Directory for Grafana to store dashboards
sudo mkdir -p /efs/grafana/provisioning

# Run Container
sudo docker run -d \
    -p 3000:3000 \
    --name grafana \
    --restart always \
    -v grafana_data:/var/lib/grafana \
    -v /efs/grafana/provisioning:/etc/grafana/provisioning \
    grafana/grafana:7.0.0