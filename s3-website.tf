resource "aws_s3_bucket" "web_bucket" {
  bucket = "www.${var.bucket_name}"
  acl    = "private"
  policy = data.aws_iam_policy_document.s3_policy.json
  force_destroy = true
  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  tags = local.common_tags
}

####################
### Data Sources ###
####################
data "aws_iam_policy_document" "s3_policy" {
  statement {
    sid       = "CloudfrontAccess"
    effect    = "Allow"
    resources = ["arn:aws:s3:::www.${var.bucket_name}"]
    actions   = ["s3:ListBucket"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_web_bucket.iam_arn]
    }
  }

  statement {
    sid       = "CloudfrontAccessObjects"
    effect    = "Allow"
    resources = ["arn:aws:s3:::www.${var.bucket_name}/*"]

    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.s3_web_bucket.iam_arn]
    }
  }

  statement {
    sid       = "CodePipelineListBucket"
    effect    = "Allow"
    resources = ["arn:aws:s3:::www.${var.bucket_name}"]

    actions = [
      "s3:ListBucket"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.codepipeline_role.arn]
    }
  }

  statement {
    sid       = "CodepipelineAccessObjects"
    effect    = "Allow"
    resources = ["arn:aws:s3:::www.${var.bucket_name}/*"]

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:PutObjectAcl"
    ]

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.codepipeline_role.arn]
    }
  }
}

