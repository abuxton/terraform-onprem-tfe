module "tfe" {
  source = "../.."
  #   tfe_license_filepath = "./test.rli"
  tfe_hostname     = "default"
  enc_password     = "password"
  console_password = "password"
  physical         = true
}
