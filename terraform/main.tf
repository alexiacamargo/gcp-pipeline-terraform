terraform {
  required_version = ">= 1.0.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project               = var.project_id
  region                = var.region
  user_project_override = true
  access_token          = "token-falso-para-teste-local"
}

resource "google_bigquery_dataset" "dataset" {
  dataset_id                  = "dataset_clima"
  location                    = var.region
  delete_contents_on_destroy = true
}

resource "google_bigquery_table" "tabela" {
  dataset_id = google_bigquery_dataset.dataset.dataset_id
  table_id   = "dados_diarios"
  deletion_protection = false

  schema = <<EOF
[
  {"name": "data", "type": "DATE", "mode": "REQUIRED"},
  {"name": "cidade", "type": "STRING", "mode": "REQUIRED"},
  {"name": "temperatura", "type": "FLOAT", "mode": "NULLABLE"},
  {"name": "condicao", "type": "STRING", "mode": "NULLABLE"}
]
EOF
}

resource "google_service_account" "sa_funcao" {
  account_id   = "sa-pipeline-clima"
  display_name = "Service Account da Cloud Function"
}

resource "google_project_iam_member" "bq_editor" {
  project = var.project_id
  role    = "roles/bigquery.dataEditor"
  member  = "serviceAccount:${google_service_account.sa_funcao.email}"
}