// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role 
resource "aws_iam_role" "sagemaker_nb_role" {

  // General
  name = "sagemaker_nb_role"

  // Assume Principal
  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "sagemaker.amazonaws.com"
        },
        "Effect" : "Allow"
      }
    ]
  })

  // TODO: BUG: Attached Managed Policies - I *THINK* CloudWatchAgentAdminPolicy is enough, but still
  // got failed metric puts..
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSageMakerFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess",
  ]
}