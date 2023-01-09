locals {
  subnet_count = length(data.aws_availability_zones.az.names)
}

variable "project" {}
variable "environment" {}
variable "vpc_cidr" {}
variable "enable_natgw" {}
