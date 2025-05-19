resource "aws_security_group" "instance_sg" {
  name        = "${var.resource_prefix}-instance-sg"
  description = "Security group for EC2 instance"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_access_cidr
    description = "SSH access"
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.web_access_cidr
    description = "HTTP access"
  }

  # HTTPS access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.web_access_cidr
    description = "HTTPS access"
  }

  # Application port access
  ingress {
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = var.web_access_cidr
    description = "Container access"
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.resource_prefix}-instance-sg"
  }
}

# KMS key for EBS encryption
resource "aws_kms_key" "ebs_key" {
  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "${var.resource_prefix}-ebs-encryption-key"
  }
}

resource "aws_kms_alias" "ebs_key_alias" {
  name          = "alias/${var.resource_prefix}-ebs-encryption-key"
  target_key_id = aws_kms_key.ebs_key.key_id
}