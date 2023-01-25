variable "project" {
    description = "GCP Project ID"
}

variable "credentials_file" {
    description = "path to credentials file"
}

variable "region" {
    default = "us-central1"
}

variable "zone" {
    default = "us-central1-a"
}

variable "name" {}

variable "domain" {}