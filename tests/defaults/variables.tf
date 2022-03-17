variable "tfe_license_filepath" {
  type        = string
  description = "Full filepath of TFE license file (`.rli` file extension). A local filepath or S3 is supported. If s3, the path should start with `s3://`."
  validation {
    condition     = fileexists(var.tfe_license_filepath)
    error_message = "You have not provided or the file does not exist or the you do not have sufficient privilages to read the file."
  }
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
variable "enc_password" {
  type        = string
  description = "Password to protect unseal key and root token of TFE embedded Vault."
  #sensitive   = true
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
