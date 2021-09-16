module "tfe" {
  source = "../.."
  // tfe_license_filepath = "./test.rli"
  tfe_hostname     = "localhost"
  enc_password     = "password"
  console_password = "password"
  physical         = true
  // run `vagrant up` from the `terraform-onprem-tfe/tests/physical-demo` folder
  connection_private_key = ".vagrant/machines/default/virtualbox/private_key"
  connection_user        = "vagrant"
  connection_port        = 2222
  tfe_license_filepath   = var.tfe_license_filepath
}
