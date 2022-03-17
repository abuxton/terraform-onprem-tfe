
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

  # TODO https://www.terraform.io/docs/language/resources/provisioners/syntax.html#destroy-time-provisioners
}
resource "null_resource" "replicated_default" {
  count = var.airgap_install == false ? var.replicated_install == true ? 1 : 0 : 0
  connection {
    type        = "ssh"
    user        = var.connection_user
    private_key = file(var.connection_private_key)
    host        = var.tfe_hostname
    port        = var.connection_port
  }
  provisioner "file" {
    content = templatefile("${path.module}/templates/replicated_install.sh.tpl", {
      public-address  = local.user_data_args.public_ip,
      private-address = local.user_data_args.private_ip
    })
    destination = "${var.tfe_install_dir}/replicated_install.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x ${var.tfe_install_dir}/replicated_install.sh",
      "sudo ${var.tfe_install_dir}/replicated_install.sh",
    ]
  }
  depends_on = [
    null_resource.tfe_install_deploy,
  ]
}
resource "null_resource" "deploy_certs" {
  count = var.tfe_cert_privkey_path ? var.tfe_cert_secret_path ? 1 : 0 : 0
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
  provisioner "file" {
    # Deploy the tfe license from var.tfe_license_filepath
    source      = var.tfe_license_filepath
    destination = "${var.tfe_install_dir}/license.rli"
  }
}

resource "null_resource" "deploy_license" {
  count = var.tfe_license_filepath ? 1 : 0
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
}
