output "ebs_volume_id" {
  description = "ID of the encrypted EBS volume"
  value       = aws_ebs_volume.encrypted_volume.id
}