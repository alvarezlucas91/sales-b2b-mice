
variable "datadog_api_key" {
  description = "The datadog api key"
  type        = string
  default     = ""
}

variable "datadog_app_key" {
  description = "The datadog app key"
  type        = string
  default     = ""
}

variable "dashboard_name" {
  description = "The dashboard full name"
  type        = string
  default     = ""
}

variable "image_name" {
  description = "The ECR image name (without the version)"
  type        = string
  default     = ""
}

variable "eks_namespace" {
  description = "Airflow namespace for team dags"
  type        = string
  default     = ""
}