resource "null_resource" "tfe_settings_deploy" {
  count = var.physical == true ? 1 : 0

  connection {
    type        = "ssh"
    user        = var.connection_user
    private_key = file(var.connection_private_key)
    host        = var.tfe_hostname
    port        = var.connection_port
  }
  provisioner "remote-exec" {
    # create directory structure for tfe /opt/tfe, and /tmp/ptfe-install
    inline = [
      "sudo mkdir -p /opt/tfe",
      "sudo chmod 0777 /opt/tfe"
    ]
  }

  provisioner "file" {
    # deploy the settings.json for tfe to /opt/tfe/.
    content = templatefile("${path.module}/templates/tfe_settings.json.tpl",
      {
        hostname          = var.tfe_hostname,
        production_type   = "",
        installation_type = var.operational_mode,
        enc_password      = var.enc_password,
    })
    destination = "/opt/tfe/settings.json"
  }
  provisioner "file" {
    # Deploy the tfe license from var.tfe_lecense_filepath
    source      = var.tfe_license_filepath
    destination = "/opt/tfe/license.rli"
  }
  # TODO https://www.terraform.io/docs/language/resources/provisioners/syntax.html#destroy-time-provisioners
}

resource "null_resource" "replicated_conf_deploy" {
  count = var.physical == true ? 1 : 0
  connection {
    type        = "ssh"
    user        = var.connection_user
    private_key = file(var.connection_private_key)
    host        = var.tfe_hostname
    port        = var.connection_port
  }
  provisioner "file" {
    # deploy replicated settings from template
    content = templatefile("${path.module}/templates/replicated_settings.conf.tpl",
      {
        DaemonAuthenticationPassword = var.console_password
      }
    )
    destination = "/opt/tfe/replicated.conf"
  }
  # purely to move things about to expected local
  provisioner "remote-exec" {
    # mv replicated.con f to /etc/replicated.conf
    inline = [
      "sudo mv /opt/tfe/replicated.conf /etc/replicated.conf",
    ]
  }
  depends_on = [
    null_resource.tfe_settings_deploy,
  ]
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
