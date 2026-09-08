##  Copyright 2023 Google LLC
##
##  Licensed under the Apache License, Version 2.0 (the "License");
##  you may not use this file except in compliance with the License.
##  You may obtain a copy of the License at
##
##      https://www.apache.org/licenses/LICENSE-2.0
##
##  Unless required by applicable law or agreed to in writing, software
##  distributed under the License is distributed on an "AS IS" BASIS,
##  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
##  See the License for the specific language governing permissions and
##  limitations under the License.

##  This code creates PoC example for Cloud IDS ##
##  It is not developed for production workload ##

# Create the IDS network
resource "google_compute_network" "ids_network" {
  project                 = var.project_id
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
  description             = "IDS network for the Cloud IDS instance and compute instance"
  # depends_on              = [time_sleep.wait_enable_service_api_ids]
}

# Create IDS Subnetwork
resource "google_compute_subnetwork" "ids_subnetwork" {
  name          = "ids-network-${var.network_region}"
  ip_cidr_range = "192.168.10.0/24"
  region        = var.network_region
  project       = var.project_id
  network       = google_compute_network.ids_network.self_link
  # Enabling VPC flow logs
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  private_ip_google_access = true
}

# Firewall rule to allow icmp & http
resource "google_compute_firewall" "ids_allow_http_icmp" {
  name      = "ids-allow-http-icmp"
  network   = google_compute_network.ids_network.self_link
  project   = var.project_id
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["192.168.10.0/24"]
  target_service_accounts = [
    google_service_account.compute_service_account.email
  ]
  allow {
    protocol = "icmp"
  }
}

resource "google_service_account" "compute_service_account" {
  project      = var.project_id
  account_id   = "compute-service-account"
  display_name = "Custom Compute Service Account"
}

# Create Server Instance
resource "google_compute_instance" "ids_victim_server" {
  project      = var.project_id
  name         = "ids-victim-server"
  machine_type = "e2-standard-2"
  zone         = var.network_zone
  shielded_instance_config {
    enable_secure_boot = true
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.ids_network.self_link
    subnetwork = google_compute_subnetwork.ids_subnetwork.self_link
  }

  service_account {
    email  = google_service_account.compute_service_account.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = "apt-get update -y;apt-get install -y nginx;"
  labels = {
    asset_type = "victim-machine"
  }
  depends_on = [
    # time_sleep.wait_enable_service_api_ids,
    google_compute_router_nat.ids_nats,
  ]
}

# Create Attacker Instance
resource "google_compute_instance" "ids_attacker_machine" {
  project      = var.project_id
  name         = "ids-attacker-machine"
  machine_type = "e2-standard-2"
  zone         = var.network_zone
  shielded_instance_config {
    enable_secure_boot = true
  }

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network    = google_compute_network.ids_network.self_link
    subnetwork = google_compute_subnetwork.ids_subnetwork.self_link
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.compute_service_account.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/script/startup.sh")
  metadata = {
    TARGET_IP      = google_compute_instance.ids_victim_server.network_interface[0].network_ip
    enable-oslogin = "TRUE"
  }
  labels = {
    asset_type = "attacker-machine"
  }
  depends_on = [
    # time_sleep.wait_enable_service_api_ids,
    google_compute_router_nat.ids_nats,
    google_compute_instance.ids_victim_server,
  ]
}

# Create a CloudRouter
resource "google_compute_router" "ids_router" {
  project = var.project_id
  name    = "ids-subnet-router"
  region  = google_compute_subnetwork.ids_subnetwork.region
  network = google_compute_network.ids_network.id
  bgp {
    asn = 64514
  }
}

# Configure a CloudNAT
resource "google_compute_router_nat" "ids_nats" {
  project                            = var.project_id
  name                               = "nat-cloud-ids-${var.vpc_network_name}"
  router                             = google_compute_router.ids_router.name
  region                             = google_compute_router.ids_router.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Configure Cloud IDS
module "cloud_ids" {
  source                              = "GoogleCloudPlatform/cloud-ids/google"
  version                             = "~> 0.4"

  project_id                          = var.project_id
  vpc_network_name                    = google_compute_network.ids_network.name
  network_region                      = var.network_region
  network_zone                        = var.network_zone
  ids_private_ip_range_name           = "ids-private-address"
  ids_private_ip_address              = null
  ids_private_ip_prefix_length        = 24
  ids_private_ip_description          = "Cloud IDS reserved IP Range"
  ids_name                            = "cloud-ids"
  severity                            = "INFORMATIONAL"
  packet_mirroring_policy_name        = "cloud-ids-packet-mirroring"
  packet_mirroring_policy_description = "Packet mirroring policy for Cloud IDS"
  instance_list                       = [google_compute_instance.ids_victim_server.id, google_compute_instance.ids_attacker_machine.id]
  subnet_list                         = [google_compute_subnetwork.ids_subnetwork.id]
  tag_list                            = ["prod", "test", "qa", "public"]
  threat_exceptions                   = ["99999", "00000"]
}
