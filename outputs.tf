output "tfe_replicated_console_url" {
  value = "https://${var.tfe_hostname}:8800"
}
output "tfe_user_data.sh" {
  value = templatefile("${path.module}/templates/tfe_user_data.sh.tpl", local.user_data_args)
}
