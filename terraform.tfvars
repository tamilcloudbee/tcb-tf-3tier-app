vpc_cidr = "172.16.0.0/16"


public_cidr_1 = "172.16.1.0/24"
private_cidr_1 = "172.16.2.0/24"
# public_cidr_2 = "172.16.3.0/24"
# private_cidr_2 = "172.16.4.0/24"

resource_prefix = "Demo-3tier-App"

key_name = "linux-alb"

common_egress_rules = [ { from_port = 0, to_port = 0, protocol = "-1", cidr_blocks = ["0.0.0.0/0"] }
]
