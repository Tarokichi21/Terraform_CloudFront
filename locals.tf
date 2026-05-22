locals {
  common_tags = {
    Project = var.project
    Env     = var.environment
    Managed = "Terraform"
  }
}