// Create IAM roles for the Grafana Instance that allow it to read from Cloudwatch

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "ml_api_instance_role" {

  // General
  name = "ml_api_instance_role"

  // Policy
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  managed_policy_arns = [
      "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]

}

// Create an Instance Profile to Attach to the Machine
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "ml_api_instance_role" {
  name = "ml_api_instance_role"
  role = aws_iam_role.ml_api_instance_role.name
}