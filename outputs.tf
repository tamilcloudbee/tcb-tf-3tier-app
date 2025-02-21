output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "public_subnet_1_id" {
  value = module.vpc_a.public_subnet_1_id
}

output "public_subnet_2_id" {
  value = module.vpc_a.public_subnet_2_id     
}

output "private_subnet_1_id" {
  value = module.vpc_a.private_subnet_1_id     
}

