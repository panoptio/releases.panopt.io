/*
 * Cast Vars
 */
variable "stack" {}
variable "app" {}
variable "domain" {}
variable "zone_id" {}
variable "acm_cert_arn" {}
variable "website_endpoint" {}
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

// Setup CloudFront
resource "aws_cloudfront_distribution" "distribution" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    // Here we're using our S3 bucket's URL!
    domain_name = "${var.website_endpoint}"
    // This can be any name to identify this origin.
    origin_id   = "${var.website_endpoint}"
  }

  enabled             = true
  default_root_object = "index.html"

  // All values are defaults from the AWS console.
  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    // This needs to match the `origin_id` above.
    target_origin_id       = "${var.website_endpoint}"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
  }

  // Here we're ensuring we can hit this distribution using www.runatlantis.io
  // rather than the domain name CloudFront gives us.
  aliases = ["${local.fqdn}"]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  // Here's where our certificate is loaded in!
  viewer_certificate {
    //acm_certificate_arn = "${aws_acm_certificate.certificate.arn}"
    acm_certificate_arn = "${var.acm_cert_arn}"
    ssl_support_method  = "sni-only"
  }
}

// This Route53 record will point at our CloudFront distribution.
resource "aws_route53_record" "aalias" {
  zone_id = "${var.zone_id}"
  name    = "${local.fqdn}"
  type    = "A"

  alias = {
    name                   = "${aws_cloudfront_distribution.distribution.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.distribution.hosted_zone_id}"
    evaluate_target_health = false
  }
}

/*
 * Return Outputs
 */