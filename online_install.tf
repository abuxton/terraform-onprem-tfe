resource "null_resource" "online_install" {
  count = var.airgap_install == false ? var.replicated_install ? 0 : 1 : 0
  connection {
    type        = "ssh"
    user        = var.connection_user
    private_key = file(var.connection_private_key)
    host        = var.tfe_hostname
    port        = var.connection_port
  }
  provisioner "file" {
    # Deploy the tfe license from var.tfe_license_filepath
    source      = var.tfe_license_filepath
    destination = "${var.tfe_install_dir}/license.rli"
  }

  // provisioner "file" {
  //   # Deploy the certs, key, cert and ca_bundle
  //   source      = var.tfe_license_filepath
  //   destination = "${var.tfe_install_dir}/license.rli"
  // }
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
