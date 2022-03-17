module "tfe" {
  source = "../.."
  // tfe_license_filepath = "./test.rli"
  tfe_hostname     = "localhost"
  physical         = true
  // run `vagrant up` from the `terraform-onprem-tfe/tests` folder
  connection_user        = "vagrant"
  connection_port        = 2222

}
