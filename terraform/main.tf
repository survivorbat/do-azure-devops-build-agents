provider "digitalocean" {
  token = var.apiToken
}

resource "digitalocean_droplet" "droplet" {
  count = var.droplet_amount
  image = "ubuntu-18-04-x64"
  name = "build_agent_${count.index}"
  region = var.droplet_region
  size = var.droplet_size

  provisioner "local-exec" {
    command = "ansible-playbook ../ansible/site.yaml -u root -i ${join(",", digitalocean_droplet.droplet.*.ipv4_address)}"

    environment = {
      azDoAccountName = var.azdo_account_name
      azDoSecretKey = var.azdo_secret_key
    }
  }
}
