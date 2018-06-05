locals {
  repo_name           = "gonzo"
  github_owner        = "ryno75"
  pipeline_name       = "testMultiSource"
  codebuild_proj_name = "gonzo-test"
  codedeploy_app_name = "gonzo-test"
  codedeploy_dg_name  = "gonzo-test"
  artifact_bucket     = "rksandbox-codepipeline-artifacts"
  webhook_name        = "${local.pipeline_name}--Source--${local.github_owner}_${local.repo_name}"
}

variable "aws_profile" {}

variable "aws_region" {
  default = "us-west-2"
}

variable "github_token" {}
