#terraform aws requierment
terraform {
    required_providers {
        aws = {
            source = "hashicorp/aws"
            version = "~> 5.0"
        }

    }
}


# aws terraform provider
provider "aws" {
    region = "${var.region}"
}
