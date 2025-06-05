data "google_client_config" "current" {}

output "project" {
  value = data.google_client_config.current.project
}