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

# provider "aws" {
#   alias  = "workload"
#   region = "il-central-1"
#   assume_role {
#     role_arn = "" # Change to role in the workload account
#   }
#   default_tags {
#     tags = {
#       created_by = "terraform"
#     }
#   }
# }

# provider "aws" {
#   alias  = "shared-networking-us"
#   region = "us-east-1"
#   assume_role {
#     role_arn = "" # Change to role in the shared-networking account
#   }
#   default_tags {
#     tags = {
#       created_by = "terraform"
#     }
#   }
# }

# provider "aws" {
#   alias  = "ingress"
#   region = "il-central-1"
#   assume_role {
#     role_arn = "" # Change to role in the ingress account
#   }
#   default_tags {
#     tags = {
#       created_by = "terraform"
#     }
#   }
# }
