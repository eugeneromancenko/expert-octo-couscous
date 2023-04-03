locals {
  gke-sa        = "${var.env}-gke-sa"
  gke-name      = "${var.env}-cluster"
  gke-node-pool = "${var.env}-node-pool"
}

resource "google_project_service" "container" {
  project = var.project
  service = "container.googleapis.com"

  timeouts {
    create = "10m"
    delete = "5m"
  }

  disable_on_destroy = true
}

resource "google_project_service" "compute" {
  project = var.project
  service = "compute.googleapis.com"

  timeouts {
    create = "10m"
    delete = "5m"
  }

  disable_on_destroy = true
}

resource "google_service_account" "gke" {
  account_id   = local.gke-sa
  display_name = "GKE Service Account"
}

resource "google_container_cluster" "primary" {
  name       = local.gke-name
  project    = var.project
  location   = var.region
  network    = google_compute_network.vpc_network.self_link
  subnetwork = google_compute_subnetwork.subnetwork.self_link

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    # use defaults
  }

  master_authorized_networks_config {
    cidr_blocks {
      display_name = google_compute_subnetwork.subnetwork.name
      cidr_block   = google_compute_subnetwork.subnetwork.ip_cidr_range
    }
  }

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = var.master-ipv4-cidr-block
  }

}

resource "google_container_node_pool" "auto_scaling_preemptible_nodes" {
  name               = "${local.gke-node-pool}-auto-scaling"
  project            = var.project
  location           = var.region
  cluster            = google_container_cluster.primary.name
  initial_node_count = 0

  autoscaling {
    total_min_node_count = 0
    total_max_node_count = 2
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  lifecycle {
    ignore_changes = [initial_node_count]
  }

  network_config {
    enable_private_nodes = true
  }

  node_config {
    image_type   = "cos_containerd"
    preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = 15
    disk_type    = "pd-standard"
    tags         = ["auto-scaling-node-pool"]

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      private-pools = "true"
      auto-scaling  = "true"
      preemptible   = "true"
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}

resource "google_container_node_pool" "no_autoscaling_nodes" {
  name       = "${local.gke-node-pool}-no-auto-scaling"
  project    = var.project
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = 1

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  network_config {
    enable_private_nodes = true
  }

  node_config {
    image_type   = "cos_containerd"
    machine_type = "e2-medium"
    disk_size_gb = 15
    tags         = ["no-auto-scaling-node-pool"]
    disk_type    = "pd-standard"
    preemptible  = false

    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    service_account = google_service_account.gke.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    labels = {
      private-pools = "true"
      auto-scaling  = "false"
      preemptible   = "false"
    }
  }

  timeouts {
    create = "30m"
    update = "30m"
    delete = "30m"
  }
}