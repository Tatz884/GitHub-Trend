resource "google_bigquery_dataset" "dataset" {
  dataset_id   = replace(var.app_name, "-", "_")
  location     = var.multi_region
  description  = "This is a dataset created with Terraform"

  labels = {
    env = "default"
  }

  delete_contents_on_destroy = true
}