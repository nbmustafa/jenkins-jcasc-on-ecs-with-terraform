
# terraform {
#   backend "s3" {
#     region = "ap-southeast-2"
#     key    = "state"
#   }
# }

data "aws_caller_identity" "current" {}

provider "aws" {
  profile    = "default"
  region     = "us-east-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

# data aws_ecr_repository service {
#   name = "nashwan"
# }

# data "aws_ecs_cluster" "ecs_cluster" {
#   cluster_name = "krd-jenkins-develop-ecs-cluster"
# }

# output cluster_arn {
#     value = data.aws_ecs_cluster.ecs_cluster.arn
# }
