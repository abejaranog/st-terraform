resource "aws_codestarconnections_connection" "github" {
  name          = "GitHub-connection"
  provider_type = "GitHub"
}

resource "aws_codepipeline" "website_pipeline" {
  name     = var.pipeline_name
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.web_bucket.id
    type     = "S3"
  }

  tags = local.common_tags


  stage {
    name = "Source"
    action {
      category         = "Source"
      name             = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source_output"]

      configuration = {
        FullRepositoryId = var.web_repo_name
        BranchName       = "master"
        ConnectionArn    = aws_codestarconnections_connection.github.arn
        DetectChanges    = true
      }
    }
  }

  stage {
    name = "Deploy_on_S3"

    action {
      name     = "S3Deploy"
      category = "Deploy"
      owner    = "AWS"
      provider = "S3"
      input_artifacts = [
      "source_output"]
      version = "1"

      configuration = {
        BucketName   = aws_s3_bucket.web_bucket.id
        Extract      = true
        CacheControl = "no-cache"
      }
    }
  }

  stage {
    name = "Invalidate_Cloudfront"

    action {
      name     = "Invalidate"
      category = "Build"
      owner    = "AWS"
      provider = "CodeBuild"
      version  = "1"
      input_artifacts = ["source_output"]
      configuration = {
        ProjectName = aws_codebuild_project.invalidate_dist.arn
      }
    }
  }
}


resource "aws_iam_role" "codepipeline_role" {
  name               = "${var.pipeline_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_codepipeline.json
  inline_policy {
    name   = "codepipeline-inline-policy"
    policy = data.aws_iam_policy_document.codepipeline_role_policy.json
  }
}


####################
### Data Sources ###
####################
data "aws_iam_policy_document" "assume_role_codepipeline" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codepipeline_role_policy" {

  statement {
    sid       = "S3ArtifactBucketAccess"
    effect    = "Allow"
    resources = ["arn:aws:s3:::www.${var.bucket_name}"]
    actions   = ["s3:ListBucket"]
  }

  statement {
    sid       = "S3ArtifactBucketObjectAccess"
    effect    = "Allow"
    resources = ["arn:aws:s3:::www.${var.bucket_name}/*"]
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectAcl"
    ]
  }
  statement {
    sid       = "CodestarConnections"
    effect    = "Allow"
    resources = [aws_codestarconnections_connection.github.arn]
    actions   = ["codestar-connections:*"]
  }

  statement {
    sid = "CodebuildStartBuild"
    effect = "Allow"
    resources = ["*"]
    actions = ["codebuild:BatchGetBuilds",
            "codebuild:StartBuild"]
  }
}