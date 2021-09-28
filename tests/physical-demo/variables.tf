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
