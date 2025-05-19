variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "app"
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

variable "container_port" {
  description = "Port that the container exposes"
  type        = number
}