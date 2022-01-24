// Create An EFS Filesystem for Training Data; this FS will be accessed from Sagemaker (AL1/AL2)
// in dev, and a P3 (Ubuntu 18.04) and DL1 instance (Ubuntu 18.04) in production.

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_file_system
resource "aws_efs_file_system" "core" {

  // General
  creation_token         = "gaudi_ml_core_efs"
  availability_zone_name = aws_subnet.subnet_pub.availability_zone
  encrypted              = true

  // Lifecyle
  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }

  // Tags
  tags = {
    Name = "gaudi_ml_core_efs"
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/efs_mount_target 
resource "aws_efs_mount_target" "ds_core_mnt_target" {

  // General
  file_system_id = aws_efs_file_system.core.id

  // Security + Network
  subnet_id = aws_subnet.subnet_pvt.id

  security_groups = [
    aws_security_group.allow_ml_core_vpc.id
  ]

  // TODO: BUG: Explicit Dependency Here -> Modifications to SG can hang
  // when this is mounted b/c of a network interface failing to dettach
  depends_on = [
    aws_security_group.allow_ml_core_vpc
  ]

}
