
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "app"
}