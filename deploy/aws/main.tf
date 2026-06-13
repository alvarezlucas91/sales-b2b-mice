terraform {
   required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
  backend "s3" {
    
  }
}
provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      team    = var.team
      product = var.product
      project = var.project
      "vy:Environment" = var.environment
      "vy:CostDomain" = var.CostDomain
      "vy:Company" = var.Company
      "vy:Owner" = var.Owner
    }
  }
}

resource "aws_iam_policy" "policy" {
  name        = "${var.team}-${var.product}-${var.project}-p"
  description = "IAM policy for project ${var.team}-${var.product}-${var.project}"
  policy = templatefile("./permissions/policy.json", {
    environment = var.env,
    account = var.account,
    team = var.team,
    product = var.product,
    project = var.project
  })
}

resource "aws_iam_role" "role" {
  name = "${var.team}-${var.product}-${var.project}-r"
  assume_role_policy = templatefile("./permissions/trust-relationships.json", {
    account = var.account,
    eks_id = var.eks_id,
    eks_namespace = var.eks_namespace,
    service_account = var.service_account,
    team = var.team,
    product = var.product,
    project = var.project
  })
}

resource "aws_iam_role_policy_attachment" "example_role_policy_attachment" {
  policy_arn = aws_iam_policy.policy.arn
  role       = aws_iam_role.role.name
}
