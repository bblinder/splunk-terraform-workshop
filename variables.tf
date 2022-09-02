variable "signalfx_key" {
  type = string
}

variable "signalfx_realm" {
  type    = string
  default = "us0"
}

variable "signalfx_api_url" {
  type    = string
  default = "https://api.signalfx.com"
}

variable "username" {
  type = string
}
