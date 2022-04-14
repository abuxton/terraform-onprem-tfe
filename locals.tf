locals {
  user_data_args = {
    tfe_install_dir                 = var.tfe_install_dir
    tfe_config_dir                  = var.tfe_config_dir
    private_ip                      = var.private-address
    public_ip                       = var.public-address
    production_type                 = var.operational_mode
    airgap_install                  = var.airgap_install
    pkg_repos_reachable_with_airgap = var.pkg_repos_reachable_with_airgap
    install_docker_before           = var.install_docker_before
    replicated_bundle_path          = var.replicated_bundle_path
    tfe_airgap_bundle_path          = var.tfe_airgap_bundle_path
    tfe_license_filepath            = var.tfe_license_filepath
    tfe_release_sequence            = var.tfe_release_sequence
    tls_bootstrap_type              = var.tls_bootstrap_type
    tfe_ca_bundle_path              = var.tfe_ca_bundle_path
    tfe_cert_secret_path            = var.tfe_cert_secret_path
    tfe_cert_privkey_path           = var.tfe_cert_privkey_path
    console_password                = var.console_password
    enc_password                    = var.enc_password
    remove_import_settings_from     = var.remove_import_settings_from
    http_proxy                      = var.http_proxy
    extra_no_proxy                  = var.extra_no_proxy
    hairpin_addressing              = var.hairpin_addressing == true ? 1 : 0
    tfe_hostname                    = var.tfe_hostname
    tbw_image                       = var.tbw_image
    custom_image_tag                = var.custom_tbw_image_tag
    capacity_concurrency            = var.capacity_concurrency
    capacity_memory                 = var.capacity_memory
    force_tls                       = var.force_tls == true ? 1 : 0
    enable_metrics_collection       = 0
    log_forwarding_enabled          = 0
    metrics_endpoint_enabled        = 0
    metrics_endpoint_port_http      = ""
    metrics_endpoint_port_https     = ""
    restrict_worker_metadata_access = var.restrict_worker_metadata_access
  }
}
