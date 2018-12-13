/*
 * Cast Vars
 */
variable "stack" {}
variable "app" {}
variable "domain" {}
variable "zone_id" {}
variable "environment" {}
variable "bucket" {}
variable "region" { default = "us-east-2"}
variable "common_tags" { type = "map" }

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

/*
 * Setup Resources
 */
// Use the AWS Certificate Manager to create an SSL cert for our domain.
resource "aws_acm_certificate" "certificate" {
  domain_name       = "${local.fqdn}"
  validation_method = "DNS"
  provider = "aws.virginia"

  tags = "${merge(
    local.tags,
    var.common_tags,
    map(
      "Name", "${local.bucket_name}"
      )
  )}"
}

// Setup the validation CNAME(s) in our Rout53 Hosted Domain
resource "aws_route53_record" "validate_dns" {
    name = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name}"
    type = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type}"
    zone_id = "${var.zone_id}"
    records = ["${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value}"]
    ttl = 60
}

// Issue the DNS based certificate validation.
resource "aws_acm_certificate_validation" "validate_cert" {
    certificate_arn = "${aws_acm_certificate.certificate.arn}"
    validation_record_fqdns = ["${aws_route53_record.validate_dns.fqdn}"]
    provider = "aws.virginia"
}

/*
 * Return Outputs
 */
 output "cert_arn" {
  value = "${aws_acm_certificate_validation.validate_cert.certificate_arn}"
}