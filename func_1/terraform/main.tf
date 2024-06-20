terraform {
  required_providers {
    google = {
      version = "5.0.0"
    }
  }
}

terraform {
  backend "gcs" {
    bucket  = "nabuminds_terraform-test"
    prefix  = "gcp/play/state"
  }
}






provider "google" {
  
  project     = var.gcp_project_name
  region      = var.region 
}


data "archive_file" "source" {
    type        = "zip"
    source_dir  = "../cloudfunction/app"
    output_path = "play-${var.solution}/${var.function_version}/function-source.zip"
}

resource "google_storage_bucket_object" "archive" {
          name   = "${data.archive_file.source.output_path}"
          bucket = "nabuminds-test-cloudfunction-archive"
          source = "${data.archive_file.source.output_path}"

          depends_on = [ data.archive_file.source]
}





resource "google_cloudfunctions_function" "play" {
  available_memory_mb          = 1024
  entry_point                  = "main"
  environment_variables        = {}
  https_trigger_security_level = "SECURE_ALWAYS"
  max_instances                 = 3000
  min_instances                 = 0
  name                          = "play-${var.solution}"
  project                       = var.gcp_project_name
  region                        = var.region
  runtime                       = "python39"
  service_account_email         = "project-ga4@nabuminds-test.iam.gserviceaccount.com"
  source_archive_bucket         = "nabuminds-test-cloudfunction-archive"
  source_archive_object         = google_storage_bucket_object.archive.name
  timeout                       = 300
  trigger_http                  = true

depends_on = [ google_storage_bucket_object.archive]
 
}



resource "google_cloud_scheduler_job" "play" {
  attempt_deadline = "180s"
  name             = "play-${var.solution}"
  paused           = false
  project          = var.gcp_project_name
  region           = var.region
  schedule         = "* 2 * * *"
  time_zone        = "Europe/Tallinn"
  http_target {
    body        = base64encode("{\"result\":\"success-${var.solution}\"}")
    headers = {
      Content-Type = "application/json"
    }
    http_method = "POST"
    uri         = "https://europe-west3-${var.gcp_project_name}.cloudfunctions.net/play-${var.solution}"
    oidc_token {
      audience              = "https://europe-west3-${var.gcp_project_name}.cloudfunctions.net/play-${var.solution}"
      service_account_email = "project-ga4@nabuminds-test.iam.gserviceaccount.com"
    }
  }
  retry_config {
    max_backoff_duration = "3600s"
    max_doublings        = 5
    max_retry_duration   = "0s"
    min_backoff_duration = "5s"
    retry_count          = 0
  }
  

  depends_on = [google_cloudfunctions_function.play]
}




