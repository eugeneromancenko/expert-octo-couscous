resource "google_compute_network" "vpc_network" {
  depends_on = [google_project_service.compute]
  
  project                 = var.project
  name                    = "${var.project}-${var.env}-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnetwork" {
  name          = "${var.project}-${var.env}-subnet"
  ip_cidr_range = var.vpc-cidr-range
  region        = var.region
  network       = google_compute_network.vpc_network.id
}
