# main.tf

# Provider configuration
provider "aws" {
  region = var.aws_region
}

# Networking module
module "networking" {
  source = "./modules/networking"

  aws_region        = var.aws_region
  vpc_cidr          = var.vpc_cidr
  public_subnet_cidr = var.public_subnet_cidr
  resource_prefix   = var.resource_prefix
}

# Security module
module "security" {
  source = "./modules/security"

  vpc_id         = module.networking.vpc_id
  container_port = var.container_port
  resource_prefix = var.resource_prefix
  ssh_access_cidr = var.ssh_access_cidr
  web_access_cidr = var.web_access_cidr
}

# Compute module
module "compute" {
  source = "./modules/compute"

  instance_type     = var.instance_type
  subnet_id         = module.networking.public_subnet_id
  security_group_id = module.security.instance_security_group_id
  key_name          = var.key_name
  aws_region        = var.aws_region
  docker_image      = var.docker_image
  container_port    = var.container_port
  host_port         = var.host_port
  resource_prefix   = var.resource_prefix
}

# Storage module
module "storage" {
  source = "./modules/storage"

  availability_zone = module.compute.instance_availability_zone
  volume_size       = var.volume_size
  kms_key_arn       = module.security.kms_key_arn
  instance_id       = module.compute.instance_id
  resource_prefix   = var.resource_prefix
}