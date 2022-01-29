variable "efs_mount_target" {
  description = "Elastic Filesystem's *mount target* shared by training instances in VPC (full object)"
  type = object({
    id         = string
    ip_address = string
  })
}

variable "subnet_pvt" {
  description = "Private subnet in Core VPC (full object)"
  type = object({
    id                   = string
    arn                  = string
    availability_zone_id = string
    availability_zone    = string
  })
}

variable "allow_ml_core_egress" {
  description = "AWS Security Group allowing HTTP/HTTPS egress (e.g. internet access) for resources in private subnets"
  type = object({
    name = string
    arn  = string
    id   = string
  })
}

variable "allow_ml_core_sg" {
  description = "AWS Security Group allowing intra-vpc traffic, specific ports allowed dependent on precise configuration (full object)"
  type = object({
    name = string
    arn  = string
    id   = string
  })
}

variable "platform_identifier" {
  description = " (Required) The platform identifier of the notebook instance runtime environment. This value can be either notebook-al1-v1 or notebook-al2-v1"
  type        = string
  default     = "notebook-al1-v1"
}

variable "instance_type" {
  description = "(Required) The name of ML compute instance type (e.g. ml.p2.xlarge)."
  type        = string
  default     = "ml.p2.xlarge"
}
