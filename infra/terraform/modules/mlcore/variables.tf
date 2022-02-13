variable "az" {
  type        = string
  description = "Availability zone to deploy resources into (full slug, e.g. us-east-1a)"
  default     = "us-east-1a"
}

variable "az_2" {
  type        = string
  description = "Availability zone to deploy resources into (full slug, e.g. us-east-1b)"
  default     = "us-east-1b"
}

// This AMI can be looked-Up in a given region with the following CLI command:
//   aws ec2 describe-images \
//      --region us-east-1 \
//      --filters "Name=name,Values=ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20211021" 
//
// Defaults to the AMI of Ubuntu 20.04 in US-EAST-1
//

variable "jump_ami" {
  type        = string
  description = "AMI ID for jump instance; use `aws ec2 describe images` to locate an acceptable AMI"
  default     = "ami-083654bd07b5da81d"
}

variable "ssh_keypair_name" {
  description = "Name of an AWS managed key pair to use for SSH within the VPC"
  type        = string
  sensitive   = true
}

variable "deployer_ip_addr" {
  description = "The IP address (or, more specifically, the CIDR range) of the deployer (or otherwise whitelisted users"
  type        = list(string)
  sensitive   = true
}