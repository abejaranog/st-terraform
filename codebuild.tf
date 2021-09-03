resource "aws_codebuild_project" "invalidate_dist" {
  name          = "${var.pipeline_name}-invalidate-stage"
  build_timeout = 5
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type = "NO_SOURCE"
    buildspec = templatefile("${path.module}/templates/buildspec.tpl", {
      distribution_id = aws_cloudfront_distribution.s3_distribution.id
    })
  }
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.pipeline_name}-build-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role_codebuild.json
  inline_policy {
    name   = "codebuild-inline-policy"
    policy = data.aws_iam_policy_document.codebuild_role_policy.json
  }
}
####################
### Data Sources ###
####################
data "aws_iam_policy_document" "assume_role_codebuild" {
  statement {
    sid     = ""
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "codebuild_role_policy" {

  statement {
    sid       = "codepipeline"
    effect    = "Allow"
    resources = ["*"]
    actions = [
      "codepipeline:PutJobFailureResult",
      "codepipeline:PutJobSuccessResult",
    ]
  }

  statement {
    sid       = "CreateInvalidation"
    effect    = "Allow"
    resources = [aws_cloudfront_distribution.s3_distribution.arn]
    actions = [
      "cloudfront:CreateInvalidation"
    ]
  }
  statement {
    sid       = ""
    effect    = "Allow"
    resources = ["arn:aws:logs:*:*:*"]

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
  }
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
      "s3:GetObject"
    ]
  }
}