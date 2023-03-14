resource "null_resource" "deploy_binaries" {
  count = var.airgap_install == true ? 1 : 0
  connection {
    type        = "ssh"
    user        = var.connection_user
    private_key = file(var.connection_private_key)
    host        = var.tfe_hostname
    port        = var.connection_port
  }
}
resource "null_resource" "airgap_install" {
  count = var.airgap_install == true ? 1 : 0
  connection {
    type        = "ssh"
    user        = var.connection_user
    private_key = file(var.connection_private_key)
    host        = var.tfe_hostname
    port        = var.connection_port
  }
  provisioner "file" {
    content     = templatefile("${path.module}/templates/tfe_user_data.sh.tpl", local.user_data_args)
    destination = "${var.tfe_install_dir}/tfe_user_data.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${var.tfe_install_dir}/tfe_user_data.sh",
      "sudo ${var.tfe_install_dir}/tfe_user_data.sh",
    ]
  }
  depends_on = [
    null_resource.tfe_install_deploy,
  ]
}
