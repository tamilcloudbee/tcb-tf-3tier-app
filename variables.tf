variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_cidr_1" {
  description = "CIDR block for the first public subnet"
  type        = string
}

variable "private_cidr_1" {
  description = "CIDR block for the first private subnet"
  type        = string
}



variable "public_cidr_2" {
  description = "CIDR block for the second public subnet"
  type        = string
}

/*
variable "private_cidr_2" {
  description = "CIDR block for the second private subnet"
  type        = string
}

*/

variable "resource_prefix" {
  description = "Prefix for all resources"
  type        = string
  
}

variable "key_name" {
  description = "Key for EC@ instance"
  type        = string
}

/*
variable "egress_rules" {
  description = "List of egress rules for the security group"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
}

*/

variable "common_egress_rules" {}


variable "project_name" {
  default = "myproject"
}




