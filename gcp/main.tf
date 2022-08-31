terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.20.0"
    }
  }
}

provider "google" {
  credentials = file("key.json")

  project  = var.PROJECT
  region  = var.REGION
  zone    = var.ZONE
}

provider "google-beta" {
  credentials = file("key.json")

  project  = var.PROJECT
  region  = var.REGION
  zone    = var.ZONE
}

variable "PROJECT" {
  type = string
}

variable "REGION" {
  type = string
  default = "us-central1"
}

variable "ZONE" {
  type = string
  default = "us-central1-c"
}

variable "COUNT" {
  type = number
  default = 3
}

data "google_compute_image" "ubuntu_2004" {
  provider = google-beta

  project = "ubuntu-os-cloud"
  family  = "ubuntu-2004-lts"
}

resource "google_compute_instance_template" "default" {
  name         = "terraform-instance"
  machine_type = "f1-micro"
  can_ip_forward = false

  disk {
    source_image = data.google_compute_image.ubuntu_2004.id
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  scheduling {
    automatic_restart = false
    preemptible = true
  }

  metadata = {
    startup-script = <<EOF

    touch /tmp/init1

    sysctl -w net.ipv4.ip_local_port_range="1024 65000"
    sysctl -w net.ipv4.tcp_tw_reuse="1"
    sysctl -w fs.file-max="3261780"
    sysctl -p

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
      
    apt-get update
    apt-get install docker-ce docker-ce-cli containerd.io -y
    curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose

    touch /tmp/init2

    echo '${file("${path.module}/../aws/Dockerfile")}' > ~/Dockerfile
    echo '${file("${path.module}/../aws/docker-compose.yml")}' > ~/docker-compose.yml
    echo '${file("${path.module}/../aws/docker_entrypoint.sh")}' > ~/docker_entrypoint.sh
    echo '${file("${path.module}/../aws/config.json")}' > ~/config.json
    
    touch /tmp/init3

    docker-compose -f ~/docker-compose.yml build
    docker-compose -f ~/docker-compose.yml up -d
    
    touch /tmp/init4

    EOF
  }
}

resource "google_compute_autoscaler" "default" {
  provider = google-beta

  name   = "my-autoscaler"
  zone   = var.ZONE
  target = google_compute_instance_group_manager.default.id

  autoscaling_policy {
    max_replicas    = var.COUNT
    min_replicas    = var.COUNT
    cooldown_period = 60
  }
}

resource "google_compute_target_pool" "default" {
  provider = google-beta
  name = "my-target-pool"
}

resource "google_compute_instance_group_manager" "default" {
  provider = google-beta

  name = "my-igm"
  zone = var.ZONE

  version {
    instance_template = google_compute_instance_template.default.id
    name              = "primary"
  }

  target_pools       = [google_compute_target_pool.default.id]
  base_instance_name = "autoscaler-sample"
}