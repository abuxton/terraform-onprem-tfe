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
    inline = [
      "sudo mkdir -p /opt/tfe",
      "sudo chmod 0777 /opt/tfe"
    ]
  }

  provisioner "file" {
    #
    content = templatefile("${path.module}/templates/tfe_settings.json.tpl",
      {
        hostname          = var.tfe_hostname,
        production_type   = "",
        installation_type = var.operational_mode,
    })
    destination = "/opt/tfe/settings.json"
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
    #
    content     = templatefile("${path.module}/templates/replicated_settings.conf.tpl", {})
    destination = "/opt/tfe/replicated.conf"
  }
  # purely to move things about to expected local
  provisioner "remote-exec" {
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
    #
    content     = templatefile("${path.module}/templates/replicated_install.sh.tpl", {})
    destination = "/opt/tfe/install.sh"
  }
  depends_on = [
    null_resource.tfe_settings_deploy,
    null_resource.replicated_conf_deploy
  ]
}
