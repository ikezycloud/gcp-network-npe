terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "~> 5.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.0"
    }
  }

  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "ikezycloud" # My TFC org
    workspaces {
      name = "gcp-network-npe" # My TFC Workspace
    }
  }
}