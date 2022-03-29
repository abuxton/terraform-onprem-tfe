# debug switch
##
variable "verbose" {
  default = false
  type    = bool
}
##
variable "public-address" {
  type        = string
  description = "public IP address for the TFE installer, can be 127.0.0.1"
  default     = "127.0.0.1"
}
variable "private-address" {
  type        = string
  description = "private IP address for TFE installer script"
  default     = "127.0.0.1"
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
