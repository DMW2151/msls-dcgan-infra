// Create Core VPC for Gaudi Experiments

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc
resource "aws_vpc" "core" {

  // General - Use a Small-ish VPC; don't need many IPs...
  cidr_block           = "172.0.0.0/20"
  instance_tenancy     = "default"
  enable_dns_hostnames = true

  // Tags
  tags = {
    Name = "gaudi_ml_core_vpc"
  }
}