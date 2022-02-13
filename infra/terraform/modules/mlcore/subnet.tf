// Create a Public and Private Subnet in The defined Availability Zone
// Defaults to: US-EAST-1A

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "subnet_pub" {

  // General
  vpc_id                  = aws_vpc.core.id
  cidr_block              = cidrsubnet(aws_vpc.core.cidr_block, 4, 1)
  availability_zone       = var.az
  map_public_ip_on_launch = true

  // Tags
  tags = {
    Name = "gaudi_ml_core_pub"
  }

}

resource "aws_subnet" "subnet_pub_2" {

  // General
  vpc_id                  = aws_vpc.core.id
  cidr_block              = cidrsubnet(aws_vpc.core.cidr_block, 4, 3)
  availability_zone       = var.az_2
  map_public_ip_on_launch = true

  // Tags
  tags = {
    Name = "gaudi_ml_core_pub_2"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet
resource "aws_subnet" "subnet_pvt" {

  // General
  vpc_id                  = aws_vpc.core.id
  cidr_block              = cidrsubnet(aws_vpc.core.cidr_block, 4, 2)
  availability_zone       = aws_subnet.subnet_pub.availability_zone
  map_public_ip_on_launch = false

  // Tags
  tags = {
    Name = "gaudi_ml_core_pvt"
  }

}
