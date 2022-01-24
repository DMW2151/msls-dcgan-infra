// Define outputs for ML Core -> Many of these are passed through as outputs 
// to the main module...


output "vpc_id" {
  description = "The core VPC for all training instances (ID Only)"
  value       = aws_vpc.core.id
}

output "subnet_pub" {
  description = "Public subnet in core VPC (full object)"
  value       = aws_subnet.subnet_pub
}

output "subnet_pvt" {
  description = "Private subnet in Core VPC (full object)"
  value       = aws_subnet.subnet_pvt
}

output "allow_ml_core_sg" {
  description = "AWS Security Group allowing intra-vpc traffic, specific ports allowed dependent on precise configuration (full object)"
  value       = aws_security_group.allow_ml_core_vpc
}

output "allow_from_deployer_sg" {
  description = "AWS Security Group allowing SSH traffic from whitelisted CIDR range (full object)"
  value       = aws_security_group.allow_deployer_sg
}

output "allow_ml_core_egress" {
  description = "AWS Security Group allowing HTTP/HTTPS egress (i.e. internet access) for resources in private subnets"
  value       = aws_security_group.allow_egress
}

output "efs_mount_target" {
  description = "Elastic Filesystem's *mount target* shared by training instances in VPC (full object)"
  value       = aws_efs_mount_target.ds_core_mnt_target
}

output "jump_ip_addr" {
  description = "Public IP address of the VPC's jump instance. Allows SSH on port 22"
  value       = aws_instance.jump.public_ip
}