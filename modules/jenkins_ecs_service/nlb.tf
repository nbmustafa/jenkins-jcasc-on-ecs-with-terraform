# ---------------------------------------------------
# NLB
# ---------------------------------------------------
resource "aws_lb" "nlb_agents" {
  name                             = "nlb-jenkins-agents"
  load_balancer_type               = "network"
  internal                         = true
  # subnets                          = var.private_subnets
  subnets                          = data.aws_subnet_ids.subnet_ids.ids
  enable_deletion_protection       = false
  enable_cross_zone_load_balancing = true
  tags                             = var.tags
}

# ---------------------------------------------------
# Target group on jenkins listening port for agent to communicate with the master
# ---------------------------------------------------
resource "aws_lb_target_group" "nlb_agents_to_master_http" {
  name        = "${var.app_name}-${var.environment}-nlb-http-tg"
  target_type = "ip"
  port        = var.master_listening_port
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.vpc.id
  tags        = var.tags

  health_check {
    path                = "/login"
    port                = var.master_listening_port
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  stickiness {
    enabled = false # nlb target group don't support stickiness
    type    = "source_ip"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group" "nlb_agents_to_master_jnlp" {
  name        = "${var.app_name}-${var.environment}-nlb-jnlp-tg"
  target_type = "ip"
  port        = var.master_jnlp_port
  protocol    = "TCP"
  vpc_id      = data.aws_vpc.vpc.id
  tags        = var.tags

  health_check {
    path                = "/login"
    port                = var.master_listening_port
    healthy_threshold   = 5
    unhealthy_threshold = 5
  }

  stickiness {
    enabled = false # nlb don't support stickiness
    type    = "source_ip"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------
# Listener 80 for the NLB
# ---------------------------------------------------
resource "aws_lb_listener" "agents_http_listener" {
  load_balancer_arn = aws_lb.nlb_agents.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_agents_to_master_http.arn
  }
}

# ---------------------------------------------------
# Listener JNLP for nlb
# ---------------------------------------------------
resource "aws_lb_listener" "agents_jnlp_listener" {
  load_balancer_arn = aws_lb.nlb_agents.arn
  port              = var.master_jnlp_port
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nlb_agents_to_master_jnlp.arn
  }
}

# Getting the network interface attached to the nlb. Their IP address will be used in the security group attached to the
# task according to the best practice
# https://docs.aws.amazon.com/elasticloadbalancing/latest/network/target-group-register-targets.html#target-security-groups
data "aws_network_interfaces" "nlb_network_interfaces" {
  filter {
    name   = "description"
    # filter with nlb id in the description
    values = ["*${split("/", aws_lb.nlb_agents.arn)[3]}*"]
  }
}

data "aws_network_interface" "private_nlb_network_interface" {
  # count = length(var.private_subnets)
  count   = length(data.aws_subnet_ids.subnet_ids.ids)
  id      = tolist(data.aws_network_interfaces.nlb_network_interfaces.ids)[count.index]
}