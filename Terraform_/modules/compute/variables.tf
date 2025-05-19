variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "subnet_id" {
  description = "ID of the subnet where to deploy the EC2 instance"
  type        = string
}

variable "security_group_id" {
  description = "ID of the security group for the EC2 instance"
  type        = string
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = null
}

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "docker_image" {
  description = "Docker image to pull and run"
  type        = string
}

variable "container_port" {
  description = "Port that the container exposes"
  type        = number
}

variable "host_port" {
  description = "Port on the host to map to the container"
  type        = number
}

variable "resource_prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "app"
}