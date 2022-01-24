variable "efs_mount_target" {
  description = "Elastic Filesystem's *mount target* shared by training instances in VPC (full object)"
  type = object({
    id         = string
    ip_address = string
  })
}

variable "subnet_pvt" {
  description = "Private subnet in Core VPC (full object)"
  type = object({
    id                   = string
    arn                  = string
    availability_zone_id = string
    availability_zone    = string
  })
}

variable "allow_ml_core_egress" {
  description = "AWS Security Group allowing HTTP/HTTPS egress (e.g. internet access) for resources in private subnets"
  type = object({
    name = string
    arn  = string
    id   = string
  })
}

variable "allow_ml_core_sg" {
  description = "AWS Security Group allowing intra-vpc traffic, specific ports allowed dependent on precise configuration (full object)"
  type = object({
    name = string
    arn  = string
    id   = string
  })
}

variable "ssh_keypair_name" {
  description = "Name of an AWS managed key pair to use for SSH within the VPC"
  type        = string
  sensitive   = true
}

variable "worker_ami" {
  type        = string
  description = "AMI ID for worker instance; use `aws ec2 describe images` to locate an acceptable AMI"
  default     = "ami-0cf1d34c09c83dc91" // DL1 in US-EAST-1
}