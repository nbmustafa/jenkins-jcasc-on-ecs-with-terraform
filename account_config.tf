locals {
  app_name                = "jenkins"
  application_id          = "APID001"
  cost_centre             = "CC001"
  iam_name_prefix         = "abc"
  service_name            = "krd"
  disable_api_termination = "false"
  # alb_access_logs_bucket  = "${local.account_id}-alb-log-bucket"
  proxy_host              = ""
  container_port          = 8080
  JenkinsJNLPPort         = 50000
  prefix_name             = "${local.service_name}-${local.app_name}-${var.environment}"

  account_configs = {
    develop = {
      route53_zone_name = "cmcloudlab834.info"
    }

    sit = {
      route53_zone_name = "cmcloudlab872.info."
    }

    prod = {
      route53_zone_name = "cmcloudlab1725.info."
    }
  }

  account_config = local.account_configs[var.environment]
}
