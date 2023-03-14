module "tfe" {
  source             = "../.."
  tfe_hostname       = "localhost"
  tfe_fqdn           = "localhost"
  physical           = true
  replicated_install = true
  // run `vagrant up` from the `terraform-onprem-tfe/tests` folder
  connection_user        = "vagrant"
  connection_port        = 2222
  connection_private_key = var.connection_private_key
  verbose                = var.verbose
  public-address         = var.public-address
  private-address        = var.private-address
}
