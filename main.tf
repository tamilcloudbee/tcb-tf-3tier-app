provider "aws" {
  region = "us-east-1"
}

module "vpc_a" {
  source          = "./modules/vpc"
  vpc_cidr        = var.vpc_cidr
  public_cidr_1   = var.public_cidr_1
  private_cidr_1  = var.private_cidr_1
  env_name        = "dev_a"
  resource_prefix = var.resource_prefix

}


module "sg_frontend" {
  source          = "./modules/security_group"
  vpc_id          = module.vpc_a.vpc_id
  env_name        = "dev_a"
  resource_prefix = join("-", [var.resource_prefix, "frontend"])

  ingress_rules = [
    { from_port = 80, to_port = 80, protocol = "tcp", cidr_blocks = ["0.0.0.0/0"] } # Allow HTTP from anywhere
  ]

  egress_rules = var.common_egress_rules
}

module "sg_fastapi" {
  source          = "./modules/security_group"
  vpc_id          = module.vpc_a.vpc_id
  env_name        = "dev_a"
  resource_prefix = join("-", [var.resource_prefix, "fastapi"])

  ingress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", source_sg_id = module.sg_frontend.security_group_id } # Allow all traffic from frontend
  ]

  egress_rules = var.common_egress_rules
}

module "sg_mysqldb" {
  source          = "./modules/security_group"
  vpc_id          = module.vpc_a.vpc_id
  env_name        = "dev_a"
  resource_prefix = join("-", [var.resource_prefix, "mysqldb"])

  ingress_rules = [
    { from_port = 0, to_port = 0, protocol = "-1", source_sg_id = module.sg_fastapi.security_group_id } # Allow all traffic from FastAPI
  ]

  egress_rules = var.common_egress_rules
}


module "ec2_frontend" {
  source              = "./modules/ec2"
  instance_type       = "t2.micro"
  public_subnet_id    = module.vpc_a.public_subnet_1_id
  user_data           = templatefile("userdata-frontend-tier1.sh", { 
                          APP_TIER_PRIVATE_IP = module.ec2_fastapi.public_instance_private_ip 
                      })
  key_name            = var.key_name
  env_name            = "dev_a"
  security_group_id   = module.sg_frontend.security_group_id
  resource_prefix     = join("-", [var.resource_prefix, "frontend"])

  depends_on = [module.ec2_fastapi]  # Ensure `ec2_fastapi` is created first
}

module "ec2_fastapi" {
  source              = "./modules/ec2"
  instance_type       = "t2.micro"
  public_subnet_id    = module.vpc_a.public_subnet_1_id
  user_data           = templatefile("userdata-fastapi-tier2.sh", { 
                          DB_TIER_IP = module.ec2_mysqldb.public_instance_private_ip 
                      })
  key_name            = var.key_name
  env_name            = "dev_a"
  security_group_id   = module.sg_fastapi.security_group_id
  resource_prefix     = join("-", [var.resource_prefix, "fastapi"])

  depends_on = [module.ec2_mysqldb]  # Ensure `ec2_mysqldb` is created first
}

module "ec2_mysqldb" {
  source              = "./modules/ec2"
  instance_type       = "t2.micro"
  public_subnet_id    = module.vpc_a.public_subnet_1_id
  user_data           = file("userdata-mysqldb-tier3.sh")
  key_name            = var.key_name
  env_name            = "dev_a"
  security_group_id   = module.sg_mysqldb.security_group_id
  resource_prefix     = join("-", [var.resource_prefix, "mysqldb"])


}



/*
module "alb" {
  source               = "./modules/alb"
  resource_prefix      = var.resource_prefix
  load_balancer_type   = "application"
  vpc_id               = module.vpc_a.vpc_id
  public_subnet_ids    = [module.vpc_a.public_subnet_1_id, module.vpc_a.public_subnet_2_id]
  security_group_ids   = [module.sg_a.alb_security_group_id]
  env_name             = "dev"
  main_instance_ids    = {
    "main_instance_1" = module.ec2_a.public_instance_id
    "main_instance_2" = module.ec2_b.public_instance_id
  }
  admin_instance_ids   = {
    "admin_instance_1" = module.ec2_a.public_instance_id
  }
  register_instance_ids = {
    "register_instance_1" = module.ec2_b.public_instance_id
  }
}
*/
