output "instance_security_group_id" {
  description = "ID of the security group for the EC2 instance"
  value       = aws_security_group.instance_sg.id
}

output "kms_key_arn" {
  description = "ARN of the KMS key used for EBS encryption"
  value       = aws_kms_key.ebs_key.arn
}

output "kms_key_id" {
  description = "ID of the KMS key used for EBS encryption"
  value       = aws_kms_key.ebs_key.id
}