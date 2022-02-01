// Jump Instance for reaching backend services from "outside" the VPC
// default to an Ubuntu 20.04 Nano Instance, but any instance in the public
// subnet will do

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "jump" {

  // General 
  // Defaults -> us-east-1; ubuntu 20.04; t3.nano
  ami           = var.jump_ami
  instance_type = "t3.nano"

  // Security + Networking
  subnet_id                   = aws_subnet.subnet_pub.id
  availability_zone           = aws_subnet.subnet_pub.availability_zone
  associate_public_ip_address = true
  vpc_security_group_ids = [
    aws_security_group.allow_ml_core_vpc.id,
    aws_security_group.allow_deployer_sg.id,
    aws_security_group.allow_egress.id
  ]

  // SSH
  key_name = var.ssh_keypair_name

  // Tags
  tags = {
    Name = "ML Core - Jump Instance"
  }

}
