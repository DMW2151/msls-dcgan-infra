data "aws_route53_zone" "dmw" {
  name         = "dmw2151.com"
  private_zone = false
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.dmw.zone_id
  name    = "api"
  type    = "CNAME"
  ttl     = "300"
  records = [
      aws_lb.model_alb.dns_name
    ]
}

// FootGun -> Need to Manually Create These Records, Blegh
data "aws_acm_certificate" "dmw" {
  domain       = "api.dmw2151.com"
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}