variable "project" {
  description = "project name"
  default     = ""
}

variable "env" {
  description = "env"
  default     = ""
}

variable "region" {
  description = "value for region"
  default     = ""
}

variable "vpc-cidr-range" {
  description = "value for vpc-cidr-range"
  type        = string
  default     = "10.2.0.0/24"
}

variable "master-ipv4-cidr-block" {
  description = "The IP range in CIDR notation use for the hosted master network"
  type        = string
  default     = "10.5.0.0/28"
}

variable "bigquery_role_assignment" {
  description = "value for bigquery_role_assignment"
  type = map(object({
    role = string
    user = string
  }))
  default = {
    vmo2_tech_test = {
      role = "roles/bigquery.dataEditor"
      user = "your-email"
    }
    # vmo2_tech_test = {
    #   role = "OWNER"
    #   user = "owner-email"
    # }
  }
}
