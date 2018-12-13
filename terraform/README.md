# releases.panopt.io - Terraform Infa Code

This is the infra-code that manages setting up all AWS resources behind the `https://releases.panopt.io` distributable binary website.  The site is statically hosted via the following AWS resources:

* `S3`: Hosts static HTML files and Distributable Binaries
* `ACM`: Manages SSL/TLS certificate used by CloudFront 
* `CloudFront`: Handles CDN and SSL/TLS termination for the site (origin is S3 bucket)
* `Route53`: Providing DNS services for your domain.

## Requirements:

* [AWS Account](https://aws.amazon.com/)
* [awscli](https://aws.amazon.com/cli/): Proper default access keys in your `~/.aws/credentials` file.
* [terraform](https://www.terraform.io/) 

## Configuration:

**Required:**

`<stack>.tfvars` - This file will define vars used to setup your infrastructure stack

```
stack       = "holocron"            # Used for tagging resources
app         = "releases"            # Used for tagging resources
environment = "prod"                # Used for tagging resources
region      = "us-east-2"           # AWS region to create stack in 
domain      = "panopt.io"           # Domain Name associated with Route53
zone_id     = "Z16WLJ8OGEHAKR"      # The Route53 Zone hosting your domain.
bucket      = "releases.panopt.io"  # The name of your S3 bucket to manage
```

**Optional:**

For portability, we prefer to leverage and S3 bucket for hosting the Terraform state files.  You can read about this [here](https://www.terraform.io/docs/backends/types/s3.html)

To do this, the following file will be required before setting up the repo:

`config.tf` - Must exist in root of the `terraform` folder.  It must include the following, where `YOURBUCKET` is the S3 bucket in your AWS account to use.

```terraform
# Store terraform's state in an S3 bucket.
terraform {
  backend "s3" {
    bucket = "YOURBUCKET"
    key    = "releases/stack.tfstate"
    region = "us-east-2"
  }
}
```

## Executing:

#### Initialize your terraform stack

```
terraform init
```

#### Execute terraform plan (with config file)

```
terraform plan -var-file="releases.tfvars"
```

#### Execute terraform apply

```
terraform apply -var-file="releases.tfvars"
```