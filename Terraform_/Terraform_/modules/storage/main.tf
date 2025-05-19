# Encrypted EBS volume
resource "aws_ebs_volume" "encrypted_volume" {
  availability_zone = var.availability_zone
  size              = var.volume_size
  encrypted         = true
  kms_key_id        = var.kms_key_arn

  tags = {
    Name = "${var.resource_prefix}-encrypted-ebs-volume"
  }
}

# Attach the encrypted EBS volume to the EC2 instance
resource "aws_volume_attachment" "ebs_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.encrypted_volume.id
  instance_id = var.instance_id
}