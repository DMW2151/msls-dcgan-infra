// Create a Sagemaker Notebook Instance w. Data EFS Mounted. Using this notebook to prototype the model 
// and do some of the preliminary work on the image representation
//
// NOTE: For cost; we'll USE AWS Linux 1 with Pytorch 1.XX.XX, a bit outdated, but when we use a P3 and DL1 
// instance in prod, we can expect a large speedup!


// Resource:  https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_code_repository
resource "aws_sagemaker_code_repository" "dcgan" {

  // General
  code_repository_name = "msls-pytorch-dcgan"

  // Repository
  git_config {
    repository_url = "https://github.com/DMW2151/msls-pytorch-dcgan"
  }
}


// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_notebook_instance_lifecycle_configuration
resource "aws_sagemaker_notebook_instance_lifecycle_configuration" "mount_efs" {

  // Basic
  name = "mount-efs-on-init"

  // Lifecycle -> Run mount on start; will not persist mount, so won't collide on subsequent
  // mounts...
  // Get the Mount IP of the VPCs Elastic Filesystem by way of Filesystem ID
  on_start = base64encode(
    templatefile(
      "${path.module}/user-data/amzn-linux2-sagemaker-init.sh",
      {
        nfs_mount_ip = var.efs_mount_target.ip_address
      }
    )
  )
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sagemaker_notebook_instance
resource "aws_sagemaker_notebook_instance" "notebook_instance" {

  // General
  name                = "dev-gaudi-sagemaker-nb-instance"
  role_arn            = aws_iam_role.sagemaker_nb_role.arn
  instance_type       = var.instance_type       // Essentially hard-coding this as: "ml.p2.xlarge" 
  platform_identifier = var.platform_identifier // Essentially hard-coding this as: "notebook-al1-v1" 

  // Init NB Instance Deps
  lifecycle_config_name = aws_sagemaker_notebook_instance_lifecycle_configuration.mount_efs.name

  // Init Repo in NB Instance
  default_code_repository = aws_sagemaker_code_repository.dcgan.code_repository_name

  // Networking + Security
  direct_internet_access = "Disabled"
  subnet_id              = var.subnet_pvt.id
  security_groups = [
    var.allow_ml_core_sg.id,
    var.allow_ml_core_egress.id
  ]

  // Tags
  tags = {
    Name = "dev-gaudi-sagemaker-nb-instance"
  }

}

