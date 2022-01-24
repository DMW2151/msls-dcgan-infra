#! /bin/sh

# Init a Grafana Instance running in Docker; Exposed to the VPC

sudo apt-get update -y &&\
    sudo apt-get install -y docker docker.io

sudo mkdir -p /home/ubuntu/provisioning

# Run Grafana on Start - This version 7.0.0 is the first on Ubuntu LTS 20.04
# should be similar to prior or subsequent versions, but solid and **stable**!
#
# On Startup: https://community.grafana.com/t/data-source-on-startup/8618
#
sudo docker run -d \
    -p 3000:3000 \
    --name grafana \
    -v grafana_data:/var/lib/grafana \
    -v /home/ubuntu/provisioning:/etc/grafana/provisioning \
    grafana/grafana:7.0.0


