variable "project_name" {
  description = "Project name used for naming resources"
  type        = string
}

variable "public_subnets" {
  description = "List of public subnets where ALB will be deployed"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where the ALB will be deployed"
  type        = string
}

variable "frontend_instance_id" {
  description = "ID of the frontend EC2 instance to attach to ALB target group"
  type        = string
}


# REMOVE THIS from variables.tf
# variable "alb_security_group" {
#   description = "Security group for the ALB"
#   type        = string
# }

