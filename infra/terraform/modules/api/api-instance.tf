

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "api" {

  // General 
  // Defaults -> us-east-1; ubuntu 20.04; t3.nano
  ami           = var.statistics_ami
  instance_type = "t3.medium"

  // Security + Networking
  subnet_id                   = var.subnet_pvt.id
  availability_zone           = var.subnet_pvt.availability_zone
  associate_public_ip_address = false
  vpc_security_group_ids = [
    var.allow_ml_core_sg.id,
    var.allow_ml_core_egress.id
  ]

  // SSH
  key_name = var.ssh_keypair_name

  // User Data Starts API in a container (:5000) on init
  iam_instance_profile = aws_iam_instance_profile.ml_api_instance_role.name
  user_data = templatefile(
    "${path.module}/user-data/api-instance-user-data.sh", {
      nfs_mount_ip = var.efs_mount_target.ip_address
    }
  )

  // Storage - Minimal Storage Required for Instance - May change w. non-default AMI 
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 20
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true

    // Tags
    tags = {
      Name = "ML Core - API"
    }

  }

  // Tags
  tags = {
    Name = "ML Core - API Instance"
  }

}
