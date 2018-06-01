provider "aws" {
  version = "1.20.0"
  region  = "${var.region}"
}

data "aws_iam_policy_document" "codepipeline_arpdoc" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals = {
      type = "Service"

      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_access" {
  statement {
    sid = "S3ReadAccess"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
    ]

    resources = ["*"]
  }

  statement {
    sid = "S3PutObjectAccess"

    actions = [
      "s3:PutObject",
    ]

    resources = [
      "arn:aws:s3:::codepipeline*",
      "arn:aws:s3:::elasticbeanstalk*",
    ]
  }

  statement {
    sid = "CodeBuildAccess"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }

  statement {
    sid = "CodeDeployAccess"

    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision",
    ]

    resources = ["*"]
  }

  statement {
    sid = "MiscServiceAccess"

    actions = [
      "elasticbeanstalk:*",
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*",
      "iam:PassRole",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "codepipeline_service"
  path               = "/codepipeline/"
  assume_role_policy = "${data.aws_iam_policy_document.codepipeline_arpdoc.json}"
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "codepipeline_service_policy"
  role   = "${aws_iam_role.codepipeline.id}"
  policy = "${data.aws_iam_policy_document.codepipeline_access.json}"
}

/*
resource "aws_codepipeline" "testMultiSourcePipeline" {
id                                                  = testMultiSourcePipeline
arn                                                 = arn:aws:codepipeline:us-west-2:779793738667:testMultiSourcePipeline
artifact_store.#                                    = 1
artifact_store.0.encryption_key.#                   = 0
artifact_store.0.location                           = codepipeline-us-west-2-347001196608
artifact_store.0.type                               = S3
name                                                = testMultiSourcePipeline
role_arn                                            = arn:aws:iam::779793738667:role/AWS-CodePipeline-Service
stage.#                                             = 2
stage.0.action.#                                    = 1
stage.0.action.0.category                           = Source
stage.0.action.0.configuration.%                    = 4
stage.0.action.0.configuration.Branch               = master
stage.0.action.0.configuration.Owner                = 2ndWatch
stage.0.action.0.configuration.PollForSourceChanges = false
stage.0.action.0.configuration.Repo                 = BeanstalkTestNodeJS
stage.0.action.0.input_artifacts.#                  = 0
stage.0.action.0.name                               = Source
stage.0.action.0.output_artifacts.#                 = 1
stage.0.action.0.output_artifacts.0                 = nodeTest
stage.0.action.0.owner                              = ThirdParty
stage.0.action.0.provider                           = GitHub
stage.0.action.0.role_arn                           =
stage.0.action.0.run_order                          = 1
stage.0.action.0.version                            = 1
stage.0.name                                        = Source
stage.1.action.#                                    = 1
stage.1.action.0.category                           = Deploy
stage.1.action.0.configuration.%                    = 2
stage.1.action.0.configuration.ApplicationName      = testNodeJS
stage.1.action.0.configuration.EnvironmentName      = Testnodejs-env
stage.1.action.0.input_artifacts.#                  = 1
stage.1.action.0.input_artifacts.0                  = nodeTest
stage.1.action.0.name                               = Testnodejs-env
stage.1.action.0.output_artifacts.#                 = 0
stage.1.action.0.owner                              = AWS
stage.1.action.0.provider                           = ElasticBeanstalk
stage.1.action.0.role_arn                           =
stage.1.action.0.run_order                          = 1
stage.1.action.0.version                            = 1
stage.1.name                                        = Staging
}
*/

resource "aws_s3_bucket" "codedeploy" {
  bucket = "${local.artifact_bucket}"
}

resource "aws_codepipeline" "testMultiSource" {
  name     = "${local.pipeline_name}"
  role_arn = "${aws_iam_role.codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.codedeploy.bucket}"
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      output_artifacts = ["gonzo-src"]
      version          = "1"
      run_order        = "1"

      configuration {
        Owner                = "${local.github_owner}"
        Repo                 = "${local.gonzo_repo}"
        Branch               = "master"
        OAuthToken           = "${var.github_token}"
        PollForSourceChanges = "false"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["gonzo-src"]
      output_artifacts = ["gonzo-bld"]
      version          = "1"
      run_order        = "2"

      configuration {
        ProjectName = "${local.codebuild_proj_name}"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CodeDeploy"
      input_artifacts = ["gonzo-bld"]
      version         = "1"
      run_order       = "3"

      configuration {
        ApplicationName     = "${local.codedeploy_app_name}"
        DeploymentGroupName = "${local.codedeploy_dg_name}"
      }
    }
  }
}
