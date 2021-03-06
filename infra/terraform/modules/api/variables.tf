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

variable "subnet_pub" {
  description = "Public subnet in Core VPC (full object)"
  type = object({
    id                   = string
    arn                  = string
    availability_zone_id = string
    availability_zone    = string
  })
}

variable "subnet_pub_2" {
  description = "Public subnet in Core VPC (full object)"
  type = object({
    id                   = string
    arn                  = string
    availability_zone_id = string
    availability_zone    = string
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


variable "allow_ml_core_egress" {
  description = "AWS Security Group allowing HTTP/HTTPS egress (e.g. internet access) for resources in private subnets"
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

// This AMI can be looked-Up in a given region with the following CLI command:
//   aws ec2 describe-images \
//      --region us-east-1 \
//      --filters "Name=name,Values=...." 
//
// Defaults to the AMI of Ubuntu 20.04 in US-EAST-1
//
variable "api_ami" {
  type        = string
  description = "AMI ID for metrics instance; use `aws ec2 describe images` to locate an acceptable AMI"
  default     = "ami-083654bd07b5da81d"
}