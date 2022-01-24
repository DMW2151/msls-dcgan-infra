// Create IAM roles for the Grafana Instance that allow it to read from Cloudwatch

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role" "stats_instance_role" {

  // General
  name = "stats_instance_role"

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
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy
resource "aws_iam_policy" "cloudwatch_stats_monitor" {

  // General
  name = "cloudwatch_stats_monitor"

  // Policies - Allow Cloudwatch, SSM, and S3
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "cloudwatch:DescribeAlarmsForMetric",
          "cloudwatch:DescribeAlarmHistory",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:ListMetrics",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:GetMetricData"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:DescribeLogGroups",
          "logs:GetLogGroupFields",
          "logs:StartQuery",
          "logs:StopQuery",
          "logs:GetQueryResults",
          "logs:GetLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : ["ec2:DescribeTags", "ec2:DescribeInstances", "ec2:DescribeRegions"],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : "tag:GetResources",
        "Resource" : "*"
      }
    ]
    }
  )
}

// TODO: Check if these are **all** needed; prefer to use a minimal policy where possible...
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role
resource "aws_iam_role_policy_attachment" "cloudwatch_stats_monitor" {
  role       = aws_iam_role.stats_instance_role.name
  policy_arn = aws_iam_policy.cloudwatch_stats_monitor.arn
}

// Create an Instance Profile to Attach to the Machine
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile
resource "aws_iam_instance_profile" "stats_instance_role" {
  name = "stats_instance_role"
  role = aws_iam_role.stats_instance_role.name
}