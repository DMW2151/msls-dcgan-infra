
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
data "aws_vpc" "ml_vpc" {

  // Kinda Sloppy – Not Resistant to Configuration Changes....
  filter {
    name   = "tag:Name"
    values = [
      "gaudi_ml_core_vpc"
    ]
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone
data "aws_route53_zone" "dmw" {
  name         = "dmw2151.com"
  private_zone = false
}

// Need to Manually Validate These Records, Blegh, Hardcoded, Blergh
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate
data "aws_acm_certificate" "dmw" {
  domain       = "api.dmw2151.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}
