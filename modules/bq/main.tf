resource "google_bigquery_dataset" "dataset" {
  for_each = var.bigquery_role_assignment

  dataset_id                  = each.key
  friendly_name               = "${each.key} dataset"
  location                    = "EU"
  default_table_expiration_ms = 3600000

  labels = {
    env = "${var.env}"
  }
}

resource "google_service_account" "bqowner" {
  account_id = "bqowner"
}

resource "google_bigquery_dataset_access" "access" {
  for_each = var.bigquery_role_assignment

  dataset_id    = google_bigquery_dataset.dataset[each.key].dataset_id
  role          = each.value.role
  user_by_email = each.value.user
}

variable "bigquery_role_assignment" {
  type = map(object({
    role = string
    user = string
  }))
}

variable "env" {
  description = "env"
  default     = ""
}
