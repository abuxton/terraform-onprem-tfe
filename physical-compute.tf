
resource "null_resource" "tfe_install_deploy" {
  count = var.physical == true ? 1 : 0

  connection {
    type        = "ssh"
    user        = var.connection_user
    private_key = file(var.connection_private_key)
    host        = var.tfe_hostname
    port        = var.connection_port
  }
  provisioner "remote-exec" {
    # create directory structure for tfe ${var.tfe_install_dir}
    inline = [
      "sudo mkdir -p ${var.tfe_install_dir}",
      "sudo chmod 0777 ${var.tfe_install_dir}"
    ]
  }

  provisioner "file" {
    content = templatefile("${path.module}/templates/tfe_user_data.sh.tpl",local.user_data_args)
      {
        hostname          = var.tfe_hostname,
        production_type   = "",
        installation_type = var.operational_mode,
        enc_password      = var.enc_password,
    })
    destination = "${var.tfe_install_dir}/tfe_user_data.sh"
  }
  provisioner "file" {
    # Deploy the tfe license from var.tfe_license_filepath
    source      = var.tfe_license_filepath
    destination = "${var.tfe_install_dir}/license.rli"
  }
  # TODO https://www.terraform.io/docs/language/resources/provisioners/syntax.html#destroy-time-provisioners
}


resource "null_resource" "replicated_install" {
  count = var.physical == true ? 1 : 0
  connection {
    type        = "ssh"
    user        = var.connection_user
    private_key = file(var.connection_private_key)
    host        = var.tfe_hostname
    port        = var.connection_port
  }
  provisioner "file" {
    # copy the shell script into /opt/tfe
    content = templatefile("${path.module}/templates/replicated_install.sh.tpl",
      {
        private-address = var.private-address,
        public-address  = var.public-address,
    })
    destination = "/opt/tfe/install.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "sudo bash +x /opt/tfe/install.sh"
    ]
  }
  depends_on = [
    null_resource.tfe_settings_deploy,
    null_resource.replicated_conf_deploy
  ]
}
