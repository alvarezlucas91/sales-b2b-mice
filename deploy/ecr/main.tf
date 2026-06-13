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

resource "aws_ecr_repository" "new_repository" {
  name = var.ecr_name
  image_tag_mutability = "MUTABLE"
  force_delete = true
  image_scanning_configuration {
    scan_on_push = true
  }
}

