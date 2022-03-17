
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
    content     = templatefile("${path.module}/templates/tfe_user_data.sh.tpl", local.user_data_args)
    destination = "${var.tfe_install_dir}/tfe_user_data.sh"
  }
  # TODO https://www.terraform.io/docs/language/resources/provisioners/syntax.html#destroy-time-provisioners
}

resource "null_resource" "online_demo" {
  count = var.airgap_install == false ? 1 : 0
  connection {
    type        = "ssh"
    user        = var.connection_user
    private_key = file(var.connection_private_key)
    host        = var.tfe_hostname
    port        = var.connection_port
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
    # Deploy the tfe license from var.tfe_license_filepath
    source      = var.tfe_license_filepath
    destination = "${var.tfe_install_dir}/license.rli"
  }
  // provisioner "file" {
  //   # Deploy the certs, key, cert and ca_bundle
  //   source      = var.tfe_license_filepath
  //   destination = "${var.tfe_install_dir}/license.rli"
  // }
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
