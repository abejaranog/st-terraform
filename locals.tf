data "aws_caller_identity" "current" {}

locals {
  common_tags = {
    Owner = "abg"
  }
  aws_account = data.aws_caller_identity.current.account_id
}