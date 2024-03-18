# main.tf

terraform {
  required_version = ">= 0.14"

  required_providers {
    # Cloud Run support was added on 3.3.0
    google = ">= 5.2"
  }
  backend "gcs" {
    bucket  = "github-trend-ringed-reach-414622"
    prefix  = "terraform/state/"
    credentials = "./secrets/ringed-reach-414622-696337488ab4.json" # for local environment. In deployment, credentials are injected from GitHub Action
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

# #############################################
# #               Enable API's                #
# #############################################
# Enable IAM API
resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

# Enable Artifact Registry API
resource "google_project_service" "artifactregistry" {
  service            = "artifactregistry.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun" {
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud Resource Manager API
resource "google_project_service" "resourcemanager" {
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

# Enable VCP Access API
resource "google_project_service" "vpcaccess" {
  service            = "vpcaccess.googleapis.com"
  disable_on_destroy = false
}

# Enable Secret Manager API
resource "google_project_service" "secretmanager" {
  service            = "secretmanager.googleapis.com"
  disable_on_destroy = false
}

# Enable Cloud SQL Admin API
resource "google_project_service" "sqladmin" {
  service            = "sqladmin.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "cloud_run_account" {
  account_id   = "${var.project_id}-cloud-run"
  display_name = "Cloud Run Service Account"
}

resource "google_secret_manager_secret" "secret" {
  secret_id = "GitHub-API-token"
  replication {
    auto{}
  }
}

resource "google_secret_manager_secret_version" "secret_version_data" {
  secret      = google_secret_manager_secret.secret.id
  secret_data = file("/home/tatz884/portfolio/github-trend/util/secrets/GitHub-API-token.txt")
}

# Create the Cloud Run service
resource "google_cloud_run_v2_service" "run_service" {
  name     = var.app_name
  location = var.region
  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  launch_stage = "BETA"
  

  template {
    execution_environment = "EXECUTION_ENVIRONMENT_GEN2"
    
    service_account = "${google_service_account.cloud_run_account.account_id}@${var.project_id}.iam.gserviceaccount.com"
    scaling {
      min_instance_count = 1
      max_instance_count = 1
    }
    vpc_access{
      connector = google_vpc_access_connector.connector.id
      egress        = "PRIVATE_RANGES_ONLY"
      
    }

    volumes {
      name = "nfs"
      nfs {
        server    = google_filestore_instance.instance.networks[0].ip_addresses[0]
        path      = "/share1"
        read_only = false
      }
    }

    containers {
      image = var.docker_image
      ports {
        container_port = 6789
      }
      
      resources {
        limits = {
          cpu    = var.container_cpu
          memory = var.container_memory
        }
      }

      volume_mounts {
        name       = "nfs"
        mount_path = "/mnt/nfs/filestore"
      }
      env {
        name  = "GCP_PROJECT_ID"
        value = var.project_id
      }
      env {
        name  = "GCP_REGION"
        value = var.region
      }
      env {
        name  = "GCP_SERVICE_NAME"
        value = var.app_name
      }
      env {
        name = "GITHUB_API_TOKEN" # Use a descriptive name for your environment variable
        value_source {
          secret_key_ref {
            secret = google_secret_manager_secret.secret.id
            version = "1"
          }
        }
      }

      # env {
      #   name  = "MAGE_DATABASE_CONNECTION_URL"
      #   value = "postgresql://${var.database_user}:${var.database_password}@/${var.app_name}-db?host=/cloudsql/${google_sql_database_instance.instance.connection_name}"
      # }
      env {
        name  = "ULIMIT_NO_FILE"
        value = 16384
      }
      # volume_mounts {
      #   mount_path = "/secrets/bigquery"
      #   name       = "secret-bigquery-key"
      # }
    }
    # volumes {
    #   name = "secret-bigquery-key"
    #   secret {
    #     secret_name  = "bigquery_key"
    #     items {
    #       key  = "latest"
    #       path = "bigquery_key"
    #     }
    #   }
    # }
    
    

  }

  # traffic {
  #   type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
  #   percent         = 100
  # }

  # Waits for the Cloud Run API to be enabled, and buckets
  depends_on = [
    google_project_service.cloudrun,
    google_storage_bucket.github_trend,
    google_service_account.cloud_run_account,
    google_secret_manager_secret_version.secret_version_data
  ]
}




# GCS Bucket Creation
resource "google_storage_bucket" "github_trend" {
  name                        = "github-trend"
  location                    = var.region
  storage_class               = "STANDARD"
  uniform_bucket_level_access = true
  force_destroy               = false

  lifecycle_rule {
    condition {
      age = 365
    }
    action {
      type = "Delete"
    }
  }
}

# Bucket IAM Policy for Cloud Run access
resource "google_storage_bucket_iam_member" "cloud_run_access" {
  bucket = google_storage_bucket.github_trend.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run_account.account_id}@${var.project_id}.iam.gserviceaccount.com"
}

# Allow unauthenticated users to invoke the service
resource "google_cloud_run_service_iam_member" "run_all_users" {
  service  = google_cloud_run_v2_service.run_service.name
  location = google_cloud_run_v2_service.run_service.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_project_iam_binding" "secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"

  members = [
    "serviceAccount:${google_service_account.cloud_run_account.account_id}@${var.project_id}.iam.gserviceaccount.com",
  ]
  depends_on=[google_secret_manager_secret.secret]
}

# Display the service IP
output "service_ip" {
  value = module.lb-http.external_ip
}

# ----------------------------------------------------------------------------------------
# Create the Cloud Run DBT Docs service and corresponding resources, uncomment if needed

# resource "google_cloud_run_service" "dbt_docs_service" {
#   name = "${var.app_name}-docs"
#   location = var.region

#   template {
#     spec {
#       containers {
#         image = var.docker_image
#         ports {
#           container_port = 7789
#         }
#         resources {
#           limits = {
#             cpu     = var.container_cpu
#             memory  = var.container_memory
#           }
#         }
#         env {
#           name  = "FILESTORE_IP_ADDRESS"
#           value = google_filestore_instance.instance.networks[0].ip_addresses[0]
#         }
#         env {
#           name  = "FILE_SHARE_NAME"
#           value = "share1"
#         }
#         env {
#           name  = "DBT_DOCS_INSTANCE"
#           value = "1"
#         }
#       }
#     }

#     metadata {
#       annotations = {
#         "autoscaling.knative.dev/minScale"         = "1"
#         "run.googleapis.com/execution-environment" = "gen2"
#         "run.googleapis.com/vpc-access-connector"  = google_vpc_access_connector.connector.id
#         "run.googleapis.com/vpc-access-egress"     = "private-ranges-only"
#       }
#     }
#   }

#   traffic {
#     percent         = 100
#     latest_revision = true
#   }

#   metadata {
#     annotations = {
#       "run.googleapis.com/launch-stage" = "BETA"
#       "run.googleapis.com/ingress"      = "internal-and-cloud-load-balancing"
#     }
#   }

#   autogenerate_revision_name = true

#   # Waits for the Cloud Run API to be enabled
#   depends_on = [google_project_service.cloudrun]
# }

# resource "google_cloud_run_service_iam_member" "run_all_users_docs" {
#   service  = google_cloud_run_service.dbt_docs_service.name
#   location = google_cloud_run_service.dbt_docs_service.location
#   role     = "roles/run.invoker"
#   member   = "allUsers"
# }

# output "docs_service_ip" {
#   value = google_compute_global_address.docs_ip.address
# }