variable "environment" {
  description = "The name of the current environment to run"
  type        = string
  default     = "Dev"
}
variable "ecr_name" {
  description = "The ECR name to be created"
  type        = string
  default     = "commercial-salesb2b-mice"
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