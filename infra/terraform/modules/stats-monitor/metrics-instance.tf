

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance
resource "aws_instance" "metrics" {

  // General 
  // Defaults -> us-east-1; ubuntu 20.04; t3.nano
  ami           = var.statistics_ami
  instance_type = "t3.small"

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

  // User Data Starts Grafana in a container (:3000) on init -> No EFS Mount 
  // and therefore no vars passed to template!
  iam_instance_profile = aws_iam_instance_profile.stats_instance_role.name
  user_data = templatefile(
    "${path.module}/user-data/stats-instance-user-data.sh", {
      nfs_mount_ip = var.efs_mount_target.ip_address
    }
  )

  // Storage - Minimal Storage Required for Instance - May change w. non-default AMI 
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 10
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true

    // Tags
    tags = {
      Name = "ML Core - Grafana"
    }

  }

  // Tags
  tags = {
    Name = "ML Model Monitor - Metrics Instance"
  }

}
