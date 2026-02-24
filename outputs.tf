# NETWORK

output "vpc_id" {
  description = "ID du VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "Liste des subnets publics"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Liste des subnets privés"
  value       = module.network.private_subnet_ids
}

output "number_of_public_subnets" {
  value = length(module.network.public_subnet_ids)
}

output "number_of_private_subnets" {
  value = length(module.network.private_subnet_ids)
}


# LOAD BALANCER


output "alb_dns_name" {
  description = "DNS public du Load Balancer"
  value       = module.alb.alb_dns_name
}

output "alb_url" {
  description = "URL HTTP du Load Balancer"
  value       = "http://${module.alb.alb_dns_name}"
}

output "target_group_arn" {
  description = "ARN du Target Group"
  value       = module.alb.target_group_arn
}


# COMPUTE


output "instance_ids" {
  description = "IDs des instances EC2 privées"
  value       = module.compute.instance_ids
}

output "number_of_instances" {
  value = length(module.compute.instance_ids)
}


# SECURITY


output "alb_security_group_id" {
  value = module.security.alb_sg_id
}

output "web_security_group_id" {
  value = module.security.web_sg_id
}


# ARCHITECTURE SUMMARY (OBJECT GLOBAL)


output "infrastructure_summary" {
  description = "Résumé complet de l'infrastructure"
  value = {
    network = {
      vpc_id              = module.network.vpc_id
      public_subnets      = module.network.public_subnet_ids
      private_subnets     = module.network.private_subnet_ids
      public_subnet_count = length(module.network.public_subnet_ids)
      private_subnet_count= length(module.network.private_subnet_ids)
    }

    load_balancer = {
      dns_name = module.alb.alb_dns_name
      url      = "http://${module.alb.alb_dns_name}"
      target_group_arn = module.alb.target_group_arn
    }

    compute = {
      instance_ids   = module.compute.instance_ids
      instance_count = length(module.compute.instance_ids)
    }

    security = {
      alb_sg = module.security.alb_sg_id
      web_sg = module.security.web_sg_id
    }
  }
}
