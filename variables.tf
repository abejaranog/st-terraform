variable "region" {
  type = string
  description = "AWS Region to deploy infrastructure on it"
}

variable "bucket_name" {
  type = string
}

variable "pipeline_name" {
  type = string
}

variable "web_repo_name" {
  type = string
}