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

# Build the API Container
git clone https://github.com/DMW2151/msls-pytorch-dcgan.git

cd msls-pytorch-dcgan &&\
    sudo docker build . -t dmw2151/deep-dash-api-flask

sudo docker run \
    --name img-api \
    -p 5000:5000 \
    --restart unless-stopped \
    --net=host \
    -v /efs/trained_model/:/efs/trained_model \
    dmw2151/deep-dash-api-flask python3 ./api/img_svc.py
