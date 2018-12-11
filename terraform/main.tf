/**
 * The stack module combines sub modules to create a complete
 * stack with `vpc`, a default ecs cluster with auto scaling
 * and a bastion node that enables you to access all instances.
 *
 * Usage:
 *
 *    module "stack" {
 *      source      = "github.com/segmentio/stack"
 *      name        = "mystack"
 *      environment = "prod"
 *    }
 *
 */

variable "stack" {
  description = "the name of your stack, e.g. \"panopt\""
}

variable "app" {
  description ="The name of the app we're dealing with, e.g. \"flitter\""
}

variable "environment" {
  description = "the name of your environment, e.g. \"prod\""
}

variable "region" {
  description = "the AWS region in which resources are created, you must set the availability_zones variable as well if you define this value to something other than the default"
  default     = "us-east-2"
}

variable "domain" {
  description = "the domain we're going to use to create our resources"
  default     = "panopt.io"
}

variable "bucket" {
  description = "The S3 bucket we will use to upload resources to."
}

variable "common_tags" {
    type = "map"
    default = {
        Contractor  = "terraform"
    }
}

variable "logs_expiration_enabled" {
  default = false
}

variable "logs_expiration_days" {
  default = 30
}

/*
 * Setup our provider to define region, etc...
 */
 provider "aws" {
  region = "${var.region}"
}

/*
 * Get our current AWS environment
 */

data "aws_caller_identity" "current" {}

/*
 * This is where we'll define our modules. 
 */

module "s3" {
  source                  = "./s3"
  stack                   = "${var.stack}"
  app                     = "${var.app}"
  domain                  = "${var.domain}"
  environment             = "${var.environment}"
  bucket                  = "${var.bucket}"
  account_id              = "${data.aws_caller_identity.current.account_id}"
  logs_expiration_enabled = "${var.logs_expiration_enabled}"
  logs_expiration_days    = "${var.logs_expiration_days}"
  common_tags             = "${var.common_tags}"
  region                  = "${var.region}"
}

/*
 * Now we'll define our outputs
 */

// The region in which the infra lives.
output "region" {
  value = "${var.region}"
}

// S3 bucket ID for ELB logs.
output "bucket_id" {
  value = "${module.s3.id}"
}

// S3 bucket ID for ELB logs.
output "log_bucket_id" {
  value = "${module.s3.log_id}"
}