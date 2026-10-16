terraform {
  required_version = ">= 1.6.0"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.40"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

variable "cloudflare_account_id" { type = string }
variable "cloudflare_api_token" { type = string, sensitive = true }
variable "project_name" { type = string, default = "ballerz-fussballschule" }
variable "domain" { type = string, default = "ballerz-fussballschule.de" }

resource "cloudflare_d1_database" "main" {
  account_id = var.cloudflare_account_id
  name       = "ballerz-db"
}

resource "cloudflare_r2_bucket" "assets" {
  account_id = var.cloudflare_account_id
  name       = "ballerz-assets"
  location   = "WEUR"
}

resource "cloudflare_pages_project" "site" {
  account_id        = var.cloudflare_account_id
  name              = var.project_name
  production_branch = "main"

  build_config {
    build_command   = "npm run build"
    destination_dir = "dist"
    root_dir        = ""
  }

  deployment_configs {
    production {
      environment_variables = {
        PUBLIC_SITE_NAME = "Ballerz Fussballschule"
        PUBLIC_SITE_URL  = "https://${var.domain}"
      }
      d1_databases = {
        DB = cloudflare_d1_database.main.id
      }
      r2_buckets = {
        ASSETS = cloudflare_r2_bucket.assets.name
      }
      compatibility_date  = "2026-10-01"
      compatibility_flags = ["nodejs_compat"]
    }
    preview {
      d1_databases = {
        DB = cloudflare_d1_database.main.id
      }
      r2_buckets = {
        ASSETS = cloudflare_r2_bucket.assets.name
      }
      compatibility_date  = "2026-10-01"
      compatibility_flags = ["nodejs_compat"]
    }
  }
}

output "d1_database_id" { value = cloudflare_d1_database.main.id }
output "r2_bucket_name" { value = cloudflare_r2_bucket.assets.name }
output "pages_project_name" { value = cloudflare_pages_project.site.name }
output "pages_url" { value = "https://${var.project_name}.pages.dev" }
