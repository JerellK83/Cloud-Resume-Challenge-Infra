terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "4.27.0"
    }
    google-beta = {
        source = "hashicorp/google-beta"
        version = "4.27.0"
    }
  }
}

provider "google" {
  credentials = file(var.credentials_file)
  project = var.project
  region = var.region
  zone = var.zone
}

provider "google-beta" {
  project = var.project
}

resource "google_storage_bucket" "static_website" {
  name          = "${var.name}-static-website-bucket"
  location      = var.region
  storage_class = "STANDARD"
  website {
    main_page_suffix = "index.html"
    not_found_page = "index.html"
  }

  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "member" {
  bucket = google_storage_bucket.static_website.name
  role = "roles/storage.objectViewer"
  member = "allUsers"
}

resource "google_compute_global_address" "default" {
  name = "${var.name}-public-ip"
}

resource "google_compute_backend_bucket" "default" {
  name = "${var.name}-backend-bucket"
  description = "Backend bucket for CDN"
  bucket_name = google_storage_bucket.static_website.name
  enable_cdn = true
}

resource "google_compute_managed_ssl_certificate" "default" {
  name = "${var.name}-cert"
  managed {
    domains = ["${var.domain}"]
  }
}

resource "google_compute_url_map" "default" {
  name = "${var.name}-http-lb"
  default_service = google_compute_backend_bucket.default.id
}

resource "google_compute_target_https_proxy" "default" {
  name = "${var.name}-target-proxy"
  url_map = google_compute_url_map.default.id
  ssl_certificates = [
    google_compute_managed_ssl_certificate.default.id
  ]
}

resource "google_compute_global_forwarding_rule" "default" {
  name = "${var.name}-forwarding-rule"
  ip_protocol = "TCP"
  load_balancing_scheme = "EXTERNAL"
  port_range = "443"
  target = google_compute_target_https_proxy.default.id
  ip_address = google_compute_global_address.default.id
}