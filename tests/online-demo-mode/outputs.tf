output "tfe_replicated_console_url" {
  value = module.tfe.tfe_replicated_console_url
}

output "tfe_user_data_script" {
  value = var.verbose ? module.tfe.tfe_user_data : ""
}


