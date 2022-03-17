module "tfe" {
  source = "../.."
  tfe_hostname     = "localhost"
	tfe_fqdn     = "localhost"
  physical         = true
  // run `vagrant up` from the `terraform-onprem-tfe/tests/physical-demo` folder
  connection_user        = "vagrant"
  connection_port        = 2222
  connection_private_key = var.connection_private_key
	verbose                = var.verbose
}
