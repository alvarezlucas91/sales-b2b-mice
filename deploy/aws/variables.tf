variable "environment" {
  description = "The name of the current environment to run"
  type        = string
  default     = "Dev"
}
variable "env" {
  description = "The name of the current environment to run"
  type        = string
  default     = "dev"
}
variable "eks_namespace" {
  description = "The name of the EKS namespace where service account is"
  type        = string
  default     = "airflow-commercial"
}
variable "service_account" {
  description = "The name of the current K8S service account"
  type        = string
  default     = "commercial-salesb2b-mice-sa"
}
variable "account" {
  description = "The name of the AWS account"
  type        = string
  default     = "123456789012"
}
variable "eks_id" {
  description = "The EKS cluster ID"
  type        = string
  default     = "51975DC143C06C1BF3406C2C2F39725E"
}
variable "team" {
  type        = string
  default     = "commercial"
}
variable "product" {
  type        = string
  default     = "salesb2b"
}
variable "project" {
  type        = string
  default     = "mice"
}
variable "Company" {
  type        = string
  default     = "Vueling Airlines S.A."
}
variable "Owner" {
  type        = string
  default     = "Sales Performance"
}
variable "CostDomain" {
  type        = string
  default     = "COMMERCIAL"
}