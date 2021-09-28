#-------------------------------------------------------------------------------------------------------------------------------------------
# Terraform related configuration variables
#-------------------------------------------------------------------------------------------------------------------------------------------
variable "tfe_license_filepath" {
  type        = string
  description = "Full filepath of TFE license file (`.rli` file extension). A local filepath or S3 is supported. If s3, the path should start with `s3://`."
  validation {
    condition     = fileexists(var.tfe_license_filepath)
    error_message = "You have not provided or the file does not exist or the you do not have sufficient privilages to read the file."
  }
}

variable "airgap_install" {
  type        = bool
  description = "Boolean for TFE installation method to be airgap. Online mode is assumed by default"
  default     = false
}
variable "physical" {
  type        = bool
  default     = true
  description = "Boolean regarding deployment on physical servers or using a virtualization provider where supported."
}

variable "operational_mode" {
  type        = string
  default     = "demo"
  description = "Operational mode has https://www.terraform.io/docs/enterprise/before-installing/index.html#operational-mode-decision, must be one of Demo(default), mounted, or external "

  validation {
    # contains https://www.terraform.io/docs/language/functions/contains.html
    condition     = contains(["demo", "mounted", "external"], var.operational_mode)
    error_message = "String value \"demo\", \"mounted\", or \"external\"."
  }
}
variable "replicated_bundle_path" {
  type        = string
  description = "Full path of Replicated bundle (`replicated.tar.gz`). This can be in an S3 bucket or local path to the execution of terraform.  Only specify if `airgap_install` is `true`. "
  default     = ""
}
variable "tfe_airgap_bundle_path" {
  type        = string
  description = "Full path of TFE airgap bundle in S3 bucket or local path to the execution of terraform. Only specify if `airgap_install` is `true`. "
  default     = ""
}

variable "tfe_release_sequence" {
  type        = number
  description = "TFE application version release sequence number within Replicated. Ignored if `airgap_install` is `true`."
  default     = 0
}
variable "console_password" {
  type        = string
  description = "Password to unlock TFE Admin Console accessible via port 8800."
  sensitive   = true
}

variable "enc_password" {
  type        = string
  description = "Password to protect unseal key and root token of TFE embedded Vault."
  sensitive   = true
}
variable "remove_import_settings_from" {
  type        = bool
  description = "Replicated setting to automatically remove the `/etc/tfe-settings.json` file (referred to as `ImportSettingsFrom` by Replicated) after installation."
  default     = false
}

variable "tfe_hostname" {
  type        = string
  description = "Hostname/FQDN of TFE instance. This name should resolve to the load balancer DNS name and will be how users and systems access TFE."
}
variable "tbw_image" {
  type        = string
  description = "Terraform Build Worker container image to use. Set this to `custom_image` to use alternative container image."
  default     = "default_image"

  validation {
    condition     = contains(["default_image", "custom_image"], var.tbw_image)
    error_message = "Supported values are `default_image` or `custom_image`."
  }
}

variable "custom_tbw_repo" {
  type        = string
  description = "Name of Repository where custom Terraform Build Worker (tbw) image exists. Only specify if `tbw_image` is set to `custom_image`."
  default     = ""
}

variable "custom_tbw_image_tag" {
  type        = string
  description = "Tag of custom Terraform Build Worker (tbw) image. Examples: `v1`, `latest`. Only specify if `tbw_image` is set to `custom_image`."
  default     = "latest"
}

variable "capacity_concurrency" {
  type        = string
  description = "Total concurrent Terraform Runs (Plans/Applies) allowed within TFE."
  default     = "10"
}

variable "capacity_memory" {
  type        = string
  description = "Maxium amount of memory (MB) that a Terraform Run (Plan/Apply) can consume within TFE."
  default     = "512"
}

variable "enable_metrics_collection" {
  type        = bool
  description = "Boolean to enable internal TFE metrics collection."
  default     = true
}

variable "force_tls" {
  type        = bool
  description = "Boolean to require all internal TFE application traffic to use HTTPS by sending a 'Strict-Transport-Security' header value in responses, and marking cookies as secure. Only enable if `tls_bootstrap_type` is `server-path`."
  default     = false
}

#-------------------------------------------------------------------------------------------------------------------------------------------
# Network related configuration variables
#-------------------------------------------------------------------------------------------------------------------------------------------

variable "http_proxy" {
  type        = string
  description = "Proxy address to configure for TFE to use for outbound connections/requests."
  default     = ""
}

variable "extra_no_proxy" {
  type        = string
  description = "A comma-separated string of hostnames or IP addresses to add to the TFE no_proxy list. Only specify if a value for `http_proxy` is also specified."
  default     = ""
}
variable "syslog_endpoint" {
  type        = string
  description = "Syslog endpoint for Logspout to forward TFE logs to."
  default     = ""
}

variable "hairpin_addressing" {
  type        = bool
  description = "Boolean to enable TFE services to direct requests to the servers' internal IP address rather than the TFE hostname/FQDN. Only enable if `tls_bootstrap_type` is `server-path`."
  default     = false
}

variable "public-address" {
  type        = string
  description = "public IP address for the TFE installer, can be 127.0.0.1"
}
variable "private-address" {
  type        = string
  description = "private IP address for TFE installer script"
  default     = "127.0.0.1"
}
#-------------------------------------------------------------------------------------------------------------------------------------------
# Compute
#-------------------------------------------------------------------------------------------------------------------------------------------

variable "os_distro" {
  type        = string
  description = "Linux OS distribution for TFE EC2 instance. Choose from `ubuntu`, `rhel`, `centos`."
  default     = "ubuntu"

  validation {
    condition     = contains(["ubuntu", "rhel", "centos"], var.os_distro)
    error_message = "Supported values are `ubuntu`, `rhel` or `centos`."
  }
}

variable "connection_user" {
  type        = string
  description = "user id for ssh key provided in string `ssh <connection_user>@127.0.0.1` defaults to root."
  default     = "root"
}
variable "connection_private_key" {
  type        = string
  default     = ""
  description = "path to private key for ssh, password is not supported. #if using vagrant TFE validate will fail if the host is not up and ssh key not present"
  validation {
    condition     = try(fileexists(var.connection_private_key), var.connection_private_key == "")
    error_message = "You have not provided or the file does not exist or the you do not have sufficient privilages to read the file."
  }
}
variable "connection_port" {
  type        = string
  description = "SSH port provided in string `ssh <connection_user>@127.0.0.1 -p <connection_port>` defaults to 22."
  default     = "22"
}
