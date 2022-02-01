// Resources: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance 
resource "aws_instance" "worker" {

  // Just *need* an Ubuntu 18.04 based AMI, but we expect the Deep Learning AMI 
  // or generally just an AMI with the following:
  //
  //  - PyTorch-1.10 
  //
  // Defaults -> us-east-1; ubuntu 18.04 DL AMI w. Habana; DL1.24xLarge...
  ami           = var.worker_ami
  instance_type = var.worker_instance_type

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

  // Block
  root_block_device {
    volume_type           = "gp3"
    volume_size           = 130 // 130GB is the minimum allowed for the snapshot of DL AMI
    iops                  = 3000
    throughput            = 125
    delete_on_termination = true
  }

  // Instance Configuration...
  iam_instance_profile = aws_iam_instance_profile.worker.name
  user_data = templatefile(
    "${path.module}/user-data/instance-init.sh",
    {
      nfs_mount_ip = var.efs_mount_target.ip_address
    }
  )

  // Tags
  tags = {
    Name = "ML Core - Worker Instance"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume
resource "aws_ebs_volume" "msls" {

  // General
  type              = "gp3"
  size              = 50
  iops              = 8000
  throughput        = 1000
  availability_zone = var.subnet_pvt.availability_zone

  // Tags
  tags = {
    Name = "MSLS Volume"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment
resource "aws_volume_attachment" "worker" {

  // General
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.msls.id
  instance_id = aws_instance.worker.id
}