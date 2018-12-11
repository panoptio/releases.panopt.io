# Store terraform's state in an S3 bucket.
terraform {
  backend "s3" {
    bucket = "panopt-tfstate"
    key    = "releases/stack.tfstate"
    region = "us-east-2"
  }
}