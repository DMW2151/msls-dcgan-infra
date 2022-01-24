// Give The Core VPC Internet Access

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway
resource "aws_internet_gateway" "core" {

  // General
  vpc_id = aws_vpc.core.id

  // Tags
  tags = {
    Name = "gaudi_igw"
  }

}