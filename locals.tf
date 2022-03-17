locals {
  user_data_args = {
    airgap_install                  = var.airgap_install
    pkg_repos_reachable_with_airgap = var.pkg_repos_reachable_with_airgap
    install_docker_before           = var.install_docker_before
    replicated_bundle_path          = var.replicated_bundle_path
    tfe_airgap_bundle_path          = var.tfe_airgap_bundle_path
    tfe_license_filepath            = var.tfe_license_filepath
    tfe_release_sequence            = var.tfe_release_sequence
    tls_bootstrap_type              = var.tls_bootstrap_type
    ca_bundle_secret_path           = var.ca_bundle_secret_arn
    console_password                = var.console_password
    enc_password                    = var.enc_password
    remove_import_settings_from     = var.remove_import_settings_from
    http_proxy                      = var.http_proxy
    extra_no_proxy                  = var.extra_no_proxy
    hairpin_addressing              = var.hairpin_addressing == true ? 1 : 0
    tfe_hostname                    = var.tfe_hostname
    tbw_image                       = var.tbw_image
    custom_tbw_ecr_repo_uri         = var.custom_tbw_ecr_repo != "" ? data.aws_ecr_repository.custom_tbw_image[0].repository_url : ""
    capacity_concurrency            = var.capacity_concurrency
    capacity_memory                 = var.capacity_memory
    enable_metrics_collection       = var.enable_metrics_collection == true ? 1 : 0
    metrics_endpoint_enabled        = var.metrics_endpoint_enabled == true ? 1 : 0
    metrics_endpoint_port_http      = var.metrics_endpoint_port_http
    metrics_endpoint_port_https     = var.metrics_endpoint_port_https
    force_tls                       = var.force_tls == true ? 1 : 0
  }
}
