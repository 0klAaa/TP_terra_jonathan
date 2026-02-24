#OUTPUTS RESEAUX
output "vpc_id" {
  description = "ID du VPC"
  value       = module.network.vpc_id
}
