variable "account" {
 description = "The name of the AWS account"
  type        = string
  default     = "123456789012"
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