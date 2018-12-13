/*
 * Cast Vars
 */
variable "stack" {}
variable "app" {}
variable "domain" {}
variable "environment" {}
variable "bucket" {}
variable "region" { default = "us-east-2"}
variable "common_tags" { type = "map" }
variable "account_id" {}
variable "logs_expiration_enabled" { default = false }
variable "logs_expiration_days" { default = 30 }

locals {
  bucket_name = "${var.bucket}"
  short_host  = "${var.app}"
  fqdn        = "${var.app}.${var.domain}"
  tags = {
        Stack       = "${var.stack}"
        App         = "${var.app}"
        Environment = "${var.environment}"
  }
}

// For use with ACM
provider "aws" {
  alias = "virginia"
  region = "us-east-1"
}

/*
 * Setup Resources
 */
data "template_file" "policy" {
  template = "${file("${path.module}/policy.json")}"

  vars = {
    bucket     = "${local.bucket_name}-logs"
    account_id = "${var.account_id}"
  }
}

// Setup the bucket we're going to use.
resource "aws_s3_bucket" "b" {
  depends_on  = ["aws_s3_bucket.logs"]
  bucket    = "${local.bucket_name}"
  acl       = "public-read"

  tags = "${merge(
    local.tags,
    var.common_tags,
    map(
      "Name", "${local.bucket_name}"
      )
  )}"

  policy = <<POLICY
{
  "Version":"2012-10-17",
  "Statement":[
    {
      "Sid":"AddPerm",
      "Effect":"Allow",
      "Principal": "*",
      "Action":["s3:GetObject"],
      "Resource":["arn:aws:s3:::${local.bucket_name}/*"]
    }
  ]
}
POLICY

  website {
    index_document = "index.html"
    error_document = "404.html"
  }

  logging {
    target_bucket = "${aws_s3_bucket.logs.id}"
    target_prefix = "logs/"
  }
}

// Stub out index.html page.
resource "aws_s3_bucket_object" "index_html" {
  bucket        = "${local.bucket_name}"
  key           = "index.html"
  source        = "files/index.html"
  content_type  = "text/html"
  etag          = "${md5(file("files/index.html"))}"
}

// Request Logging Bucket
resource "aws_s3_bucket" "logs" {
  bucket = "${local.bucket_name}-logs"
  acl    = "log-delivery-write"

  lifecycle_rule {
    id      = "logs-expiration"
    prefix  = ""
    enabled = "${var.logs_expiration_enabled}"

    expiration {
      days  = "${var.logs_expiration_days}"
    }
  }

  tags = "${merge(
    local.tags,
    var.common_tags,
    map(
      "Name", "${local.bucket_name}-logs"
      )
  )}"

  policy = "${data.template_file.policy.rendered}"
}

/*
 * Return Outputs
 */
output "log_id" {
  value = "${aws_s3_bucket.logs.id}"
}

output "id" {
  value = "${aws_s3_bucket.b.id}"
}

output "website_endpoint" {
  value = "${aws_s3_bucket.b.website_endpoint}"
}