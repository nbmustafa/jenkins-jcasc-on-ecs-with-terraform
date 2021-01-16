# ---------------------------------------------------
# Jenkins Master Security Group
# ---------------------------------------------------
resource "aws_security_group" "jenkins_master_sg" {
  name        = "${local.prefix}-jenkins-master-service-sgr"
  description = "Jenkins Master ECS service security group."
  vpc_id      = data.aws_vpc.vpc.id
  tags        = merge({ "Name" : "sgr-jenkins-master-service" }, var.tags)
}

resource "aws_security_group_rule" "jenkins_master_ingress_alb" {
  security_group_id        = aws_security_group.jenkins_master_sg.id
  from_port                = var.master_listening_port
  to_port                  = var.master_listening_port
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = aws_security_group.alb_security_group.id
  description              = "From ALB to Jenkins Master listening port."
}

resource "aws_security_group_rule" "allow_agents_to_jks_jnlp_port" {
  # count             = length(var.private_subnets)
  count             = length(data.aws_subnet_ids.subnet_ids.ids)
  security_group_id = aws_security_group.jenkins_master_sg.id
  from_port         = var.master_jnlp_port
  to_port           = var.master_jnlp_port
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = list("${data.aws_network_interface.private_nlb_network_interface[count.index].private_ip}/32")
  description       = "From NLB to Jenkins Master JNLP via ENI ${data.aws_network_interface.private_nlb_network_interface[count.index].id}."
}

# When using a private nlb we need to have this rule for nlb health check to work.
resource "aws_security_group_rule" "from_private_nlb_network_interfaces" {
  # count             = length(var.private_subnets)
  count             = length(data.aws_subnet_ids.subnet_ids.ids)
  security_group_id = aws_security_group.jenkins_master_sg.id
  from_port         = var.master_listening_port
  to_port           = var.master_listening_port
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = list("${data.aws_network_interface.private_nlb_network_interface[count.index].private_ip}/32")
  description       = "From NLB to Jenkins Master HTTP via ENI ${data.aws_network_interface.private_nlb_network_interface[count.index].id}. Required for health check."
}

resource "aws_security_group_rule" "master_egress_all" {
  security_group_id = aws_security_group.jenkins_master_sg.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ---------------------------------------------------
# ALB Security Group
# ---------------------------------------------------
resource "aws_security_group" "alb_security_group" {
  name        = "${local.prefix}-jenkins-master-alb-sgr"
  description = "Jenkins Master ALB security group."
  vpc_id      = data.aws_vpc.vpc.id
  tags        = merge({ "Name" : "sgr-jenkins-master-alb" }, var.tags)
}

resource "aws_security_group_rule" "alb_ingress_http" {
  security_group_id = aws_security_group.alb_security_group.id
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_ingress_https" {
  count             = var.route53_zone_name != "" ? 1 : 0
  security_group_id = aws_security_group.alb_security_group.id
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  type              = "ingress"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_egress_all" {
  security_group_id = aws_security_group.alb_security_group.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}


# ---------------------------------------------------
# Jenkins Agent Security Group
# ---------------------------------------------------
resource "aws_security_group" "jenkins_agents" {
  name        = "${local.prefix}-jenkins-agents-sgr"
  description = "Security group attached to Jenkins agents running in Fargate."
  vpc_id      = data.aws_vpc.vpc.id
  tags        = merge({ "Name" : "sgr-jenkins-agents" }, var.tags)
}

resource "aws_security_group_rule" "jenkins_agent_egress" {
  security_group_id = aws_security_group.jenkins_agents.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}

# ---------------------------------------------------
# EFS Security Group
# ---------------------------------------------------
resource "aws_security_group" "efs" {
  name        = "sgr-jenkins-master-efs"
  description = "Jenkins Master EFS security group."
  vpc_id      = data.aws_vpc.vpc.id
  tags        = merge({ "Name" : "sgr-jenkins-master-efs" }, var.tags)
}

resource "aws_security_group_rule" "allow_jenkins_to_efs" {
  security_group_id        = aws_security_group.efs.id
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  type                     = "ingress"
  description              = "Jenkins Master access to EFS."
  source_security_group_id = aws_security_group.jenkins_master_sg.id
}
