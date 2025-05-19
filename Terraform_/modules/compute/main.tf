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

# EC2 instance
resource "aws_instance" "server" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [var.security_group_id]
  key_name                    = var.key_name
  user_data                   = local.user_data
  user_data_replace_on_change = true

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    delete_on_termination = true
  }

  tags = {
    Name = "${var.resource_prefix}-server"
  }
}