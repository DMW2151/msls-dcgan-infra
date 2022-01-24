

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter
resource "aws_ssm_parameter" "cloudwatch_agent_cfg" {
  name  = "cw_agent__config"
  type  = "String"
  value = filebase64("${path.module}/cfg/cloudwatch_agent_nb.json")
}