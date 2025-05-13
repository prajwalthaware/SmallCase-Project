# Provider configuration
provider "aws" {
  region = var.aws_region
}

# Variables
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "eu-west-3"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.medium"
}

variable "volume_size" {
  description = "20"
  type        = number
  default     = 20
}

variable "key_name" {
  description = "prajwalone.pem"
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

# Data sources for dynamic AMI selection based on region
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# User data script for instance initialization
locals {
  user_data = <<-EOF
#!/bin/bash
# Update the system
sudo yum update -y

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker

# Pull the Docker image
sudo docker pull ${var.docker_image}

# Run the Docker container
sudo docker run -d --name app -p ${var.host_port}:${var.container_port} ${var.docker_image}

# Install and configure Nginx
sudo amazon-linux-extras install nginx1 -y
sudo systemctl start nginx
sudo systemctl enable nginx

# Configure Nginx as a reverse proxy
sudo cat > /etc/nginx/conf.d/app.conf << 'EOL'
server {
  listen 80;  # Listen on port 80 for incoming HTTP requests
  server_name localhost;  # Server name or domain name this block will respond to
  location / {
    proxy_pass http://127.0.0.1:${var.host_port};  # Proxy requests to the backend server
    proxy_set_header Host $host;  # Set the Host header to the client's original host
    proxy_set_header X-Real-IP $remote_addr;  # Set the X-Real-IP header to the client's IP address
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;  # Append client's IP addresses to X-Forwarded-For header
    proxy_set_header X-Forwarded-Proto $scheme;  # Set the X-Forwarded-Proto header to the client's protocol (http or https)
  }
}
EOL

# Remove default Nginx configuration
sudo rm -f /etc/nginx/conf.d/default.conf

# Test Nginx configuration
sudo nginx -t

# Reload Nginx to apply changes
sudo systemctl reload nginx

# Format and mount the encrypted EBS volume
sudo mkfs -t xfs /dev/xvdf
sudo mkdir -p /data
sudo mount /dev/xvdf /data
echo "/dev/xvdf /data xfs defaults,nofail 0 2" | sudo tee -a /etc/fstab
EOF
}


# VPC and networking resources
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# Security group for EC2 instance
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for EC2 instance"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }

  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Container access"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "instance-sg"
  }
}

# KMS key for EBS encryption
resource "aws_kms_key" "ebs_key" {
  description             = "KMS key for EBS volume encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name = "ebs-encryption-key"
  }
}

resource "aws_kms_alias" "ebs_key_alias" {
  name          = "alias/ebs-encryption-key"
  target_key_id = aws_kms_key.ebs_key.key_id
}

# EC2 instance
resource "aws_instance" "server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.instance_sg.id]
  key_name                    = var.key_name
  user_data                   = local.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    Name = "ec2-server"
  }
}

# Encrypted EBS volume
resource "aws_ebs_volume" "encrypted_volume" {
  availability_zone = aws_instance.server.availability_zone
  size              = var.volume_size
  encrypted         = true
  kms_key_id        = aws_kms_key.ebs_key.arn

  tags = {
    Name = "encrypted-ebs-volume"
  }
}

# Attach the encrypted EBS volume to the EC2 instance
resource "aws_volume_attachment" "ebs_attachment" {
  device_name = "/dev/sdf"
  volume_id   = aws_ebs_volume.encrypted_volume.id
  instance_id = aws_instance.server.id
}

# Output values
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.server.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.server.public_ip
}

output "ebs_volume_id" {
  description = "ID of the encrypted EBS volume"
  value       = aws_ebs_volume.encrypted_volume.id
}

output "kms_key_id" {
  description = "ID of the KMS key used for encryption"
  value       = aws_kms_key.ebs_key.id
}