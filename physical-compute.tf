resource "null_resource" "tfe_installer_deploy" {
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
    destination = "/opt/tfe/replicated_settings.conf"
  }
  provisioner "file" {
    #
    content     = templatefile("${path.module}/templates/tfe_settings.json.tpl", {})
    destination = "/opt/tfe/tfe_settings.json"
  }
  provisioner "file" {
    #
    content     = templatefile("${path.module}/templates/replicated_install.sh.tpl", {})
    destination = "/opt/tfe/replicated_install.sh"
  }
}
