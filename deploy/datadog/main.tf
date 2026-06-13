terraform {
  required_providers {
    datadog = {
      source = "DataDog/datadog"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  required_version = ">= 0.14.9"
  backend "s3" {
  }
}


provider "aws" {
  region = "eu-west-1"
}

provider "datadog" {
  api_key = var.datadog_api_key
  app_key = var.datadog_app_key
  api_url = "https://api.datadoghq.eu/"
}

resource "datadog_dashboard_json" "dashboard_json" {
  dashboard = templatefile("./dashboard.json", {
    dashboard_name = var.dashboard_name,
    image_name= var.image_name,
    eks_namespace= var.eks_namespace
    })
}
