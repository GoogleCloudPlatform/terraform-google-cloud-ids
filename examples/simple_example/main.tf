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


# Enable the necessary API services
resource "google_project_service" "ids_api_service" {
  for_each = toset([
    "servicenetworking.googleapis.com",
    "ids.googleapis.com",
    "logging.googleapis.com",
    "compute.googleapis.com",
  ])
  service                    = each.key
  project                    = var.project_id
  disable_on_destroy         = true
  disable_dependent_services = true
}



# wait delay after enabling APIs
resource "time_sleep" "wait_enable_service_api_ids" {
  depends_on       = [google_project_service.ids_api_service]
  create_duration  = "60s"
  destroy_duration = "60s"
}


#Get the default the service Account
data "google_compute_default_service_account" "default" {
  project    = var.project_id
  depends_on = [time_sleep.wait_enable_service_api_ids]
}



# Create the IDS network
resource "google_compute_network" "ids_network" {
  project                 = var.project_id
  name                    = var.vpc_network_name
  auto_create_subnetworks = false
  description             = "IDS network for the Cloud IDS instance and compute instance"
  depends_on              = [time_sleep.wait_enable_service_api_ids]
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
  depends_on = [
    google_compute_network.ids_network,
  ]
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
    data.google_compute_default_service_account.default.email
  ]
  allow {
    protocol = "icmp"
  }
  depends_on = [
    google_compute_network.ids_network
  ]
}


/*
# Enable SSH through IAP
resource "google_compute_firewall" "ids_allow_iap_proxy" {
  name      = "ids-allow-iap-proxy"
  network   = google_compute_network.ids_network.self_link
  project   = var.project_id
  direction = "INGRESS"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["35.235.240.0/20"]
  target_service_accounts = [
    data.google_compute_default_service_account.default.email
  ]
  depends_on = [
    google_compute_network.ids_network
  ]
}
*/

resource "google_service_account" "compute_service_account" {
  project      = var.project_id
  account_id   = "compute-service-account"
  display_name = "Service Account"
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
  depends_on = [
    time_sleep.wait_enable_service_api_ids,
    google_compute_router_nat.ids_nats,
    #   google_compute_packet_mirroring.cloud_ids_packet_mirroring,
  ]

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
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }
  metadata_startup_script = "apt-get update -y;apt-get install -y nginx;"
  labels = {
    asset_type = "victim-machine"
  }
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
  depends_on = [
    time_sleep.wait_enable_service_api_ids,
    google_compute_router_nat.ids_nats,
    google_compute_instance.ids_victim_server,
  ]

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
    email  = data.google_compute_default_service_account.default.email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = file("${path.module}/script/startup.sh")
  metadata = {
    TARGET_IP      = "${google_compute_instance.ids_victim_server.network_interface.0.network_ip}"
    enable-oslogin = "TRUE"
  }
  labels = {
    asset_type = "attacker-machine"
  }
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
  depends_on = [google_compute_router.ids_router]
}



module "cloud_ids" {
  source                              = "../../"
  project_id                          = var.project_id
  vpc_network_name                    = var.vpc_network_name
  network_region                      = var.network_region
  network_zone                        = var.network_zone
  ids_private_ip_range_name           = "ids-private-address"
  ids_private_ip_address              = "10.10.10.0"
  ids_private_ip_prefix_length        = 24
  ids_private_ip_description          = "Cloud IDS reserved IP Range"
  ids_name                            = "cloud-ids"
  severity                            = "INFORMATIONAL"
  packet_mirroring_policy_name        = "cloud-ids-packet-mirroring"
  packet_mirroring_policy_description = "Packet mirroring policy for Cloud IDS"
  instance_list                       = ["${google_compute_instance.ids_victim_server.id}", "${google_compute_instance.ids_attacker_machine.id}"]
  subnet_list                         = ["${google_compute_subnetwork.ids_subnetwork.id}"]
  tag_list                            = var.tag_list

  depends_on = [
    google_compute_instance.ids_victim_server,
    google_compute_instance.ids_attacker_machine,
    google_compute_subnetwork.ids_subnetwork,
  ]
}
