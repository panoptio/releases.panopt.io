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
  tags = {
        Stack       = "${var.stack}"
        App         = "${var.app}"
        Environment = "${var.environment}"
  }
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

resource "aws_s3_bucket" "b" {
  depends_on  = ["aws_s3_bucket.logs"]
  bucket    = "${local.bucket_name}"
  acl       = "private"

  tags = "${merge(
    local.tags,
    var.common_tags,
    map(
      "Name", "${local.bucket_name}"
      )
  )}"

  logging {
    target_bucket = "${aws_s3_bucket.logs.id}"
    target_prefix = "logs/"
  }
}

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