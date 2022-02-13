// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
resource "aws_lb" "model_alb" {

  // General
  name               = "model-alb"
  load_balancer_type = "application"
  internal           = false

  // Network - internet-facing - allow all traffic 
  security_groups = [
    aws_security_group.model_lb_sg.id,
    var.allow_ml_core_sg.id,
    var.allow_ml_core_egress.id

  ]

  subnets         = [
    var.subnet_pub.id, var.subnet_pub_2.id
  ]

  // TODO: Logging Configuration
  // access_logs {
  //   bucket  = "dmw2151-service-logs"
  //   enabled = true
  // }

  // Misc - Ensure Resources Force Delete!!
  enable_deletion_protection = false
  lifecycle {
    prevent_destroy = false
  }

  // Tags
  tags = {
    Name = "model-alb"
  }

}

resource "aws_security_group" "model_lb_sg" {

  // General
  name                   = "model-lb-sg"
  vpc_id                 = data.aws_vpc.ml_vpc.id
  description            = "Allows incoming TCP traffic on 443 (HTTPS)"
  revoke_rules_on_delete = true

  // Ingress/Egress Rules 
  ingress {
    from_port        = 443
    to_port          = 443
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Ingress/Egress Rules 
  ingress {
    from_port        = 80
    to_port          = 80
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Expect LB is internet facing, send TCP traffic to anywhere
  egress {
    from_port        = 0
    to_port          = 65535
    protocol         = "TCP"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  // Tags 
  tags = {
    name = "tf-svc-logs-lb-sg"
  }

}

// Kinda Lazy...
// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/vpc
data "aws_vpc" "ml_vpc" {

  filter {
    name   = "tag:Name"
    values = [
      "gaudi_ml_core_vpc"
    ]
  }

}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resource/lb_target_group
resource "aws_lb_target_group" "model" {
  name     = "model-lb-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.ml_vpc.id
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group_attachment
resource "aws_lb_target_group_attachment" "instance_one" {
  target_group_arn = aws_lb_target_group.model.arn
  target_id        = aws_instance.api.id
  port             = 5000
}

// Resource: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resource/lb_listener
resource "aws_lb_listener" "gallery" {
  load_balancer_arn = aws_lb.model_alb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.dmw.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.model.arn
  }
}