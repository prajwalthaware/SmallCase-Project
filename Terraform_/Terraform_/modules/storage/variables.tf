variable "availability_zone" {
  description = "Availability zone where to create the EBS volume"
  type        = string
}

variable "volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for EBS encryption"
  type        = string
}

variable "instance_id" {
  description = "ID of the EC2 instance to attach the volume to"
  type        = string
}

variable "resource_prefix" {
  description = "Prefix to add to resource names"
  type        = string
  default     = "app"
}