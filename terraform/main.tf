provider "digitalocean" {
  token = var.apiToken
}

# The actual droplets
resource "digitalocean_droplet" "droplet" {
  count = var.droplet_amount
  image = "ubuntu-18-04-x64"
  name = "buildagent-${count.index}"
  region = var.droplet_region
  size = var.droplet_size
  ssh_keys = [digitalocean_ssh_key.agent_key.id]

  provisioner "remote-exec" {
    connection {
      host = self.ipv4_address
      user = "root"
      type = "ssh"
      private_key = tls_private_key.private_key.private_key_pem
    }

    command = "apt install python3"
  }

  provisioner "local-exec" {
    connection {
      host = self.ipv4_address
      user = "root"
      type = "ssh"
      private_key = tls_private_key.private_key.private_key_pem
    }

    command = "ansible-playbook ./ansible/site.yaml -u root -i ${join(",", digitalocean_droplet.droplet.*.ipv4_address)},"

    environment = {
      azDoAccountName = var.azdo_account_name
      azDoSecretKey = var.azdo_secret_key
      ANSIBLE_HOST_KEY_CHECKING = false
    }
  }
}

# SSH key
resource "tls_private_key" "private_key" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "digitalocean_ssh_key" "agent_key" {
  name = "agent-key"
  public_key = tls_private_key.private_key.public_key_openssh
}
