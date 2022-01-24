// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role 
resource "aws_iam_role" "worker" {

  // General
  name = "ml_worker"

  // Assume Policy
  assume_role_policy = jsonencode({
    "Version" = "2012-10-17"
    "Statement" = [
      {
        "Action" = "sts:AssumeRole"
        "Effect" = "Allow"
        "Principal" = {
          "Service" = "ec2.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchAgentAdminPolicy",
  ]

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile 
resource "aws_iam_instance_profile" "worker" {
  name = "ml_worker"
  role = aws_iam_role.worker.name
}

