// NOTE: This isn't so smooth because of ACM validation, but the name will still get added to the route
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.dmw.zone_id
  name    = "api"
  type    = "CNAME"
  ttl     = "300"
  records = [
      aws_lb.model_alb.dns_name
    ]
}

