terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }
  required_version = ">= 0.14.9"
  backend "s3" {

  }
}

provider "kubectl" {
  load_config_file = false
}

resource "kubectl_manifest" "serviceaccount" {
  yaml_body = templatefile("./templates/serviceaccount.yaml", {
    account = var.account
    eks_namespace = var.eks_namespace
    team = var.team
    product = var.product
    project = var.project,
    service_account= var.service_account
  })
}
