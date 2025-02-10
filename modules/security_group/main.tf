

/*
resource "aws_security_group" "ec2_sg" {
  name        = "${var.resource_prefix}-ec2-sg"
  description = "Allow inbound traffic from ALB to EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.alb_sg.id]  # Allow traffic from ALB's SG
  }

    ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    #security_groups = [aws_security_group.alb_sg.id]  # Allow traffic from ALB's SG
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}-ec2-sg"
  }
}

*/

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

/*
resource "aws_security_group" "alb_sg" {
  name        = "${var.resource_prefix}-alb-sg"
  description = "Allow traffic from ALB to EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow all incoming HTTP traffic
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.resource_prefix}-alb-sg"
  }
}
*/
