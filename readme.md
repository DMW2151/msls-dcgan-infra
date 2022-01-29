
# About

This repository provisions the AWS infrastructure used to train a deep learning model using either Sagemaker or Habana DL1 instances. Specifically, this infrastructure aids in training a Pytorch [re-implementation of DCGAN]([msls-dcgan](https://github.com/DMW2151/msls-pytorch-dcgan)). Generally, the system architecture can be described by the image below:

![msls-gan-architecture](images/arch.png)

## Usage

**N.B**:

- **WARNING:** This module deploys live resources into your AWS account, please be mindful of the costs associated with those resources.
  
- **NOTE:** This module does not download (nor provision pipelines to download) MSLS data, you may access it from your own signed URL [here](https://www.mapillary.com/dataset/places)

If you're so inclined, you can replicate the full architecure by running `terraform apply` from this repository. However, I suspect your time would be better served by simply cloning `msls-dcgan` to a standalone Sagemaker or EC2 (`DL1`) instance. If you're resolute in your desire to run this precise architecture, please review the variable definitions in each of the modules' `variable.tf` files and adjust accordingly.

In practice, only one of `train-model` or `train-model-dev` modules is run at a time, although if you're conscientious about stopping your instances, there's no reason both can't run simultaneously.

--------

### Core

The core module contains the networking and security features required for the remaining resources in the infrastructure. Notably, this module deploys:

- A VPC with two subnets (1 public, 1 private) in the same availability zone (**Note:**  `DL1` and `P3` instances are not available in all regions and zones ).
- A jump instance in the VPC's public subnet
- An AWS Elastic Filesystem (EFS) that can be mounted from the VPC's private subnet

--------

### Development - Sagemaker P3.8xLarge

I used Sagemaker Notebook instances to develop the model's core functionality and get a rough comparison of the training performance of `DL1` against a GPU-backed instance.

This module, `train-dev`, launches a Sagemaker Notebook instance into the VPC's private subnet, clones my model code from [Github](https://github.com/DMW2151/msls-pytorch-dcgan), and mounts the EFS volume to the instance. In the background, this instance is configured such that it's exporting GPU and memory statistics to CloudWatch.

I was able to develop and test the model's functionality on `ml.p2.xlarge` (`$0.90/hr`) instances, however this instance type is not a reasonable comparison to the `DL1`. Instead, this module launches a `ml.p3.8xlarge` (`$12.45/hr`) notebook instance. Specific reasons for this choice in the context of the project are discussed in my [main post](https://dmw2151.com/trained-a-gan).

Once in the Sagemaker console, the model can be trained by running the notebook `./models/gaudi_dcgan_nb.ipynb`.

--------

### Production - AWS Habana Deep Learning AMI - DL1.24xLarge

I used a `DL1.24xlarge` running the Deep Learning AMI as my main training instance. This machine runs in the VPC's private subnet and must be accessed via SSH tunnelling. 

The module `train-prod` provisions this machine and outputs the value of the instance's internal IP as `training_instance_ip` . Using this IP and the `jump_ip_addr` from `mlcore`, a user can SSH to the instance.

```bash
# SSH Local to Jump
ssh -A ubuntu@${JUMP_IP} -i ${PATH_TO_KEY}

# SSH Jump to DL1
ssh ubuntu@${TRAINING_INSTANCE_IP}
```

As with the Sagemaker Notebook instance, the init script for this instance handles configuring mounts, permissions, and metrics. Once in the instance, the model can be trained with just the following:

```bash
source activate pytorch_p38

python3 run_gaudi_dcgan.py \
    --dataroot "/efs/images/" \
    --seed 215 \
    --name msls_2022_01_24_001 \
    --s_epoch 0 \
    --n_epoch 16
```

--------

### Grafana - Stats Monitor

[Grafana](https://grafana.com/) is an open source analytics & monitoring solution that can be used to create charts from a variety of external data sources. A Grafana instance is not required to perform any model training or analysis, although many of the charts from my [main post](https://dmw2151.com/trained-a-gan) have been generated from the Grafana UI.

The module `stats-monitor` launches a Grafana instance in the core VPC and generates a `metrics_ip_addr`. Using this address and the `jump_ip_addr` from `mlcore`, a user can SSH tunnel the metrics instance UI to `localhost` with the following:

```bash
#! /bin/sh
ssh -L \
    127.0.0.1:3000:${INTERNAL_IP}:3000 \
    ubuntu@${JUMP_IP} \
    -i ${PATH_TO_KEY}
```

If this module is successful, you can navigate to `localhost:3000` in a browser and see the Grafana loign screen as below. Please refer to the Grafana 7.0.0 Docker [documentation](https://community.grafana.com/t/data-source-on-startup/8618) to understand how to begin using your Grafana distribution from there.

<center>
     <figure class="image">
        <img alt="Grafana Login" src="./images/grafana.png" width="500" />
        <figcaption>Grafana Login. Running in VPC, accessed via localhost:3000</figcaption>
    </figure>
</center>
