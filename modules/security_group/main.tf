

resource "aws_security_group" "ec2_sg" {
  name        = "${var.resource_prefix}-${var.env_name}-sg"
  description = "Security Group for ${var.env_name}"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_rules
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = lookup(ingress.value, "cidr_blocks", null)
      security_groups = lookup(ingress.value, "source_sg_id", null) != null ? [ingress.value.source_sg_id] : null
    }
  }

  dynamic "egress" {
    for_each = var.egress_rules
    content {
      from_port   = egress.value.from_port
      to_port     = egress.value.to_port
      protocol    = egress.value.protocol
      cidr_blocks = egress.value.cidr_blocks
    }
  }

  tags = {
    Name = "${var.resource_prefix}-${var.env_name}-sg"
  }
}
