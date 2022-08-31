terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 1.0"
    }
  }

  backend "s3" {
    region         = "us-east-1"
    key            = "terraform.tfstate"
  }
}


# Configure the AWS Provider
provider "aws" {
  region = "eu-west-1"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "template_file" "init" {
  template = "${file("${path.module}/provision.sh")}"
  vars = {
    dockerfile = file("${path.module}/Dockerfile")
    dockercompose = file("${path.module}/docker-compose.yml")
    entrypoint = file("${path.module}/docker_entrypoint.sh")
    scale = var.scale_on_instance
  }
}

data "aws_iam_policy" "ssm_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "logs_access" {
  name = "CloudWatchLogsFullAccess"
}

resource "aws_iam_role" "ssm_connect" {
  name = "ssm_connect_${var.region}"
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

resource "aws_iam_instance_profile" "ssm_connect" {
  name = "ssm_connect_${var.region}"
  role = aws_iam_role.ssm_connect.name
}

resource "aws_cloudwatch_log_group" "bombardier" {
  count = var.region == "us-east-1" ? 1 : 0
  name = "bombardier"
  retention_in_days = 1
}

resource "aws_launch_template" "main" {
  depends_on    = [aws_cloudwatch_log_group.bombardier] 
  name_prefix   = "example"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "c5.large"
  user_data = base64encode(data.template_file.init.rendered)
  iam_instance_profile {
    name = aws_iam_instance_profile.ssm_connect.name
  }
}

resource "aws_autoscaling_group" "main" {
  capacity_rebalance  = true
  desired_capacity    = var.instances
  max_size            = var.instances
  min_size            = 0
  availability_zones  = data.aws_availability_zones.available.names

  instance_refresh {
    strategy = "Rolling"
  }

  # launch_template {
  #   launch_template_id = aws_launch_template.main.id
  #   version = "$Latest"
  # }

  mixed_instances_policy {
    instances_distribution {
      spot_allocation_strategy                 = "lowest-price"
    }

    launch_template {
      launch_template_specification {
        launch_template_id = aws_launch_template.main.id
        version = "$Latest"
      }

      override {
        instance_type     = "c5d.large"
      }

      override {
        instance_type     = "c5n.large"
      }

      override {
        instance_type     = "c5.large"
      }

      override {
        instance_type     = "c4.large"
      }

      override {
        instance_type     = "c3.large"
      }
    }
  }
}
