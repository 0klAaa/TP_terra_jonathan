# MODULE NETWORK
module "network" {
  source = "./module/network"
  client      = var.client
  environment = var.environment

  create_vpc = true
  vpc_cidr   = "10.0.0.0/16"

  public_subnets = [
    {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "us-east-1a"
    },
    {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "us-east-1b"
    }
  ]

  private_subnets = [
    {
      cidr_block        = "10.0.10.0/24"
      availability_zone = "us-east-1a"
    },
    {
      cidr_block        = "10.0.20.0/24"
      availability_zone = "us-east-1b"
    }
  ]
}

# MODULE SECURITY

module "security" {
  source = "./module/security"
  client      = var.client
  environment = var.environment

  vpc_id = module.network.vpc_id
}


# MODULE ALB

module "alb" {
  source = "./module/alb"
  client      = var.client
  environment = var.environment

  vpc_id            = module.network.vpc_id
  public_subnet_ids = module.network.public_subnet_ids
  alb_sg_id         = module.security.alb_sg_id
}


# MODULE COMPUTE (EC2)

module "compute" {
  source = "./module/compute"
  client      = var.client
  environment = var.environment
  
  vpc_id              = module.network.vpc_id
  private_subnet_ids  = module.network.private_subnet_ids
  web_sg_id           = module.security.web_sg_id
  target_group_arn    = module.alb.target_group_arn
}
