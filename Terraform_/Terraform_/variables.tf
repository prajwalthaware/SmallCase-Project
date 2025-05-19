variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "ap-south-1"
}

variable "resource_prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "app"
}

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

variable "ssh_access_cidr" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "web_access_cidr" {
  description = "CIDR blocks allowed for web access"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 20
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = null
}

variable "docker_image" {
  description = "Docker image to pull and run"
  type        = string
  default     = "prajwalthaware/prajwalone"
}

variable "container_port" {
  description = "Port that the container exposes"
  type        = number
  default     = 8081
}

variable "host_port" {
  description = "Port on the host to map to the container"
  type        = number
  default     = 8081
}