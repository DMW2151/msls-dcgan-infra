// Configure routing for the Core ML VPC -> Simple comfig since just 1 public and 1 private subnet
// hardcoding us-east-1a (as I believe it's got the ability to launch both P3 and DL1 instances) 

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "main" {

  // General  - Associate with Main VPC
  vpc_id = aws_vpc.core.id

  // Routes - Allow All IPV4 and IPV6 through the subnet's intermet
  // gateway
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.core.id
  }

  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.core.id
  }

  // Tags
  tags = {
    Name = "gaudi_default_rt_tbl"
  }

}

// https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/main_route_table_association
resource "aws_main_route_table_association" "asc-main-vpc" {
  vpc_id         = aws_vpc.core.id
  route_table_id = aws_route_table.main.id
}


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip
resource "aws_eip" "core" {

  // General
  vpc = true

  // Tags
  tags = {
    Name   = "gaudi_vpc_nat_eip_${replace(var.az, "-", "_")}"
    subnet = aws_subnet.subnet_pub.id
  }

  // Dependencies - NAT <> IGW <> EIP to prevent a race. o ensure proper 
  // ordering, it is recommended to add an explicit dependency on the 
  // Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.core
  ]

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/nat_gateway
resource "aws_nat_gateway" "nat" {

  // General 
  allocation_id = aws_eip.core.id
  subnet_id     = aws_eip.core.tags.subnet

  // Dependencies - NAT <> IGW <> EIP to prevent a race. o ensure proper 
  // ordering, it is recommended to add an explicit dependency on the 
  // Internet Gateway for the VPC.
  depends_on = [
    aws_internet_gateway.core
  ]

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table
resource "aws_route_table" "private" {

  // General
  vpc_id = aws_vpc.core.id

  // TODO: Routes - All non-local traffic uses the NAT; else `local` - Check if `local`
  // rule needs to be defined
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.subnet_pvt.id
  route_table_id = aws_route_table.private.id
}
