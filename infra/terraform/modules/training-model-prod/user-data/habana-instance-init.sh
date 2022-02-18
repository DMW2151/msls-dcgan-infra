#! /bin/bash

# Confirm All Habana Requirements are up-to-date; this should be fine given we're running
# on the Habana DLAMI
curl -X GET https://vault.habana.ai/artifactory/api/gpg/key/public | sudo apt-key add -- &&\
    lsb_release -c | awk '{print $2}'

sudo dpkg --configure -a &&\
    sudo apt-get update &&\
    sudo apt install linux-headers-$(uname -r)

sudo apt install -y \
    dkms \
    libelf-dev

sudo apt install -y \
    habanalabs-firmware\
    habanalabs-thunk\
    habanalabs-firmware-tools \
    habanalabs-graph \
    
## Data Mounting....

# Mount EFS - This is Instance Metadata; Expect this NFS location to be used for logging
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${nfs_mount_ip}:/ /efs

# Mount EBS - This is where the MSLS Dataset should live; we assume this is already a partitioned
# drive; should **NOT** format in the cloud-init
sudo mkdir -p /data &&\
    sudo mount -t ext4 /dev/nvme1n1 /data

## Format and Mount /data on a good drive
sudo mkdir -p /datanvme &&\
    sudo mkfs -t ext4 /dev/nvme5n1 &&\
    sudo mount -t ext4 /dev/nvme5n1 /datanvme

# Pull the Habana Pytorch Container && the latest version of the MSLS training code...
docker pull vault.habana.ai/gaudi-docker/1.2.0/ubuntu18.04/habanalabs/pytorch-installer-1.10.0:1.2.0-585

## MSLS training - Training Loop Integrated with Habana Examples
git clone https://github.com/DMW2151/Model-References.git
