locals {
  gonzo_repo          = "gonzo"
  github_owner        = "ryno75"
  pipeline_name       = "testMultiSource"
  codebuild_proj_name = "gonzo"
  codedeploy_app_name = "gonzo"
  codedeploy_dg_name  = "gonzo-test"
  artifact_bucket     = "rksandbox-codepipeline-artifacts"
}

variable "region" {
  default = "us-west-2"
}

variable "github_token" {}
