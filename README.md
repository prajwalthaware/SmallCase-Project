# SmallCase-Project
End-to-end Infrastructure as Code deployment using Terraform and Docker — provisions an AWS EC2 instance with encrypted EBS volume and deploys a FastAPI app via Docker, accessible through public IP.


🛠 Tech Stack
Terraform (IaC)

AWS (EC2, EBS, KMS, VPC, Security Groups)

Docker & Docker Hub

Python 3.9 + FastAPI

NGINX (reverse proxy)


📦 Docker Hub: prajwalthaware/prajwalone


☁️ Terraform Resources
✅ EC2 instance with Amazon Linux 2 AMI

✅ KMS Key and Alias for volume encryption

✅ EBS Volume (20GB, encrypted, mounted on /data)

✅ Custom VPC, Subnet, IGW, Route Table

✅ Security Group (allows 22, 80, 443, 8081)


📥 Outputs
EC2 Instance ID

Public IP

EBS Volume ID

KMS Key ID


