terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.58.0"
    }
  }
}

provider "google-beta" {
  project = var.project
  region  = var.region
}

provider "google" {
  project = var.project
  region  = var.region
}

terraform {
  backend "gcs" {
  }
}