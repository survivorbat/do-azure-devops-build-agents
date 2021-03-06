variable "droplet_amount" {
  type = number
  default = "__dropletAmount__"
}

variable "droplet_size" {
  type = string
  default = "__dropletSize__"
}

variable "apiToken" {
  type = string
  default = "__apiToken__"
}

variable "droplet_region" {
  type = string
  default = "__dropletRegion__"
}

variable "azdo_secret_key" {
  type = string
  default = "__azureDevOpsSecretKey__"
}

variable "azdo_account_name" {
  type = string
  default = "__azureDevOpsAccountName__"
}
