terraform {

  backend "s3" {
    bucket = "dmw2151-state"
    key    = "state_files/gaudi-env-core.tf"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.61.0"
    }
  }

  required_version = ">= 1.0.3"

}

// Providers
provider "aws" {
  region  = "us-east-1"
  profile = "dmw2151"
}


// Get Current IP Address for SSH into VPC
data "http" "deployer_ip_addr" {
  url = "http://ipv4.icanhazip.com"
}

// Module: DS Core Networking - Exports the Core Resources for Model Training
module "mlcore" {
  source           = "../modules/mlcore"
  az               = "us-east-1a"
  ssh_keypair_name = "public-jump-1"
  deployer_ip_addr = [
    "${chomp(data.http.deployer_ip_addr.body)}/32"
  ]
}

// Module: Creates a Grafana + Tensorboard Instance in the VPC
module "stats-monitor" {
  source               = "../modules/stats-monitor"
  ssh_keypair_name     = "public-jump-1"
  subnet_pvt           = module.mlcore.subnet_pvt
  efs_mount_target     = module.mlcore.efs_mount_target
  allow_ml_core_sg     = module.mlcore.allow_ml_core_sg
  allow_ml_core_egress = module.mlcore.allow_ml_core_egress
}

// Module: Creates a small instance for serving the model's generated images
module "imgs-api" {
  source               = "../modules/api"
  ssh_keypair_name     = "public-jump-1"
  subnet_pvt           = module.mlcore.subnet_pvt
  subnet_pub           = module.mlcore.subnet_pub
  subnet_pub_2         = module.mlcore.subnet_pub_2
  efs_mount_target     = module.mlcore.efs_mount_target
  allow_ml_core_sg     = module.mlcore.allow_ml_core_sg
  allow_ml_core_egress = module.mlcore.allow_ml_core_egress
}

// Module: Creates a Sagemaker notebook for Plotting Model Metrics; Useful to have
// a UI and a standardized GPU...
module "train-aux" {
  source               = "../modules/training-model-aux"
  subnet_pvt           = module.mlcore.subnet_pvt
  efs_mount_target     = module.mlcore.efs_mount_target
  allow_ml_core_sg     = module.mlcore.allow_ml_core_sg
  allow_ml_core_egress = module.mlcore.allow_ml_core_egress
  instance_type        = "ml.t3.large"
}

// Module: Run *The* Training Instance - Runs DLAMI or Habana DLAMI
module "train-prod" {
  source               = "../modules/training-model-prod"
  ssh_keypair_name     = "public-jump-1"
  subnet_pvt           = module.mlcore.subnet_pvt
  allow_ml_core_sg     = module.mlcore.allow_ml_core_sg
  efs_mount_target     = module.mlcore.efs_mount_target
  allow_ml_core_egress = module.mlcore.allow_ml_core_egress
  worker_ami           = "ami-055f042dfbbbd5be1" // (Deep Learn AMI Gaudi: `ami-055f042dfbbbd5be1` No-Gaudi: `ami-083abc80c473f5d88`)
  worker_instance_type = "dl1.24xlarge"       // dl1.24xlarge OR p3.8xlarge for dev,
}


