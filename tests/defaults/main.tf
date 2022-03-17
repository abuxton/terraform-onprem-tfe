module "tfe" {
  source = "../.."
  // tfe_license_filepath = "./test.rli"
  tfe_hostname     = "localhost"
  enc_password     = var.enc_password
  console_password = "password"
  physical         = true
  // run `vagrant up` from the `terraform-onprem-tfe/tests/physical-demo` folder
  connection_user        = "vagrant"
  connection_port        = 2222
  tfe_license_filepath   = var.tfe_license_filepath
  public-address         = var.public-address
  private-address        = var.private-address
  connection_private_key = var.connection_private_key
}
