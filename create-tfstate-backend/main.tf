# Terraform bucket and dynamodb lock table
resource "aws_s3_bucket" "terraform_state" {
  bucket = var.aws_s3_bucket

  tags = {
    "iteratelabs:CloudService" = "s3",
    "info:Terraform"           = "True"
  }

  versioning {
    enabled = true
  }

  lifecycle_rule {
    enabled = true
    noncurrent_version_expiration {
      days = 30
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "AES256"
        kms_master_key_id = ""
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



# Terraform backend and providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 1.0.1"

}

provider "aws" {
   region = "us-east-1"

}
resource "aws_iam_role" "ssm_connect" {
  name = "ssm_connect"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  managed_policy_arns = [data.aws_iam_policy.ssm_core.arn, data.aws_iam_policy.logs_access.arn]
}

data "aws_iam_policy" "ssm_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "logs_access" {
  name = "CloudWatchLogsFullAccess"
}

