// Define core security groups for the VPC; assumes we only need two SGs
//   1. SSH into VPC
//   2. Intra VPC All Traffic - Can be pruned as needed
// 

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "allow_ml_core_vpc" {

  // General
  name                   = "gaudi_ml_vpc_allow_all"
  vpc_id                 = aws_vpc.core.id
  description            = "Allows All Intra-VPC Communications on All Ports"
  revoke_rules_on_delete = true

  // Ingress/Egress Rules - Allow all IPV4 Traffic in the VPC
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.core.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [aws_vpc.core.cidr_block]
  }

  // Tags
  tags = {
    Name = "gaudi_ml_vpc_allow_all"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "allow_deployer_sg" {

  // General
  name                   = "allow_deployer_sg"
  vpc_id                 = aws_vpc.core.id
  description            = "Allows SSH access from the IP of the System Deployer/Admin"
  revoke_rules_on_delete = true

  // Ingress/Egress Rules
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.deployer_ip_addr // NOTE: Expect `deployer_ip_addr` as list(string) w. all whitelisted addrs
  }

  // Tags
  tags = {
    Name = "gaudi_ml_allow_deployer_ssh"
  }

}


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group
resource "aws_security_group" "allow_egress" {

  // General
  name                   = "allow_ml_core_egress"
  vpc_id                 = aws_vpc.core.id
  description            = "Allow HTTP/HTTPS egress (i.e. internet access) for resources in private subnets"
  revoke_rules_on_delete = true

  // Ingress/Egress Rules
  egress {
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Tags
  tags = {
    Name = "gaudi_ml_allow_egress"
  }

}