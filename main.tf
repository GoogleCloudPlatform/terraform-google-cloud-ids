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

# Setup Private IP access ###
resource "google_compute_global_address" "ids_private_ip" {
  name          = var.ids_private_ip_range_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  address       = var.ids_private_ip_address
  prefix_length = var.ids_private_ip_prefix_length
  network       = "projects/${var.project_id}/global/networks/${var.vpc_network_name}"
  project       = var.project_id
  description   = var.ids_private_ip_description
}

# Create Private Connection: ####
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = "projects/${var.project_id}/global/networks/${var.vpc_network_name}"
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.ids_private_ip.name]
  depends_on              = [google_compute_global_address.ids_private_ip]
}

# Creating the IDS Endpoint ####
resource "google_cloud_ids_endpoint" "ids_endpoint" {
  name              = var.ids_name
  location          = var.network_zone
  network           = "projects/${var.project_id}/global/networks/${var.vpc_network_name}"
  severity          = var.severity
  project           = var.project_id
  threat_exceptions = var.threat_exceptions
  depends_on = [
    google_service_networking_connection.private_vpc_connection,
  ]
}

#Creating the packet mirroring policy for the subnet ####
resource "google_compute_packet_mirroring" "cloud_ids_packet_mirroring" {
  name        = var.packet_mirroring_policy_name
  description = var.packet_mirroring_policy_description
  project     = var.project_id
  region      = var.network_region
  network {
    url = "projects/${var.project_id}/global/networks/${var.vpc_network_name}"
  }
  collector_ilb {
    url = google_cloud_ids_endpoint.ids_endpoint.endpoint_forwarding_rule
  }
  mirrored_resources {
    tags = var.tag_list == null ? [] : var.tag_list

    dynamic "subnetworks" {
      for_each = var.subnet_list == null ? [] : var.subnet_list
      content {
        url = subnetworks.value
      }
    }

    dynamic "instances" {
      for_each = var.instance_list == null ? [] : var.instance_list
      content {
        url = instances.value
      }
    }
  }
  filter {
    ip_protocols = var.ip_protocols_filter
    cidr_ranges  = var.cidr_ranges_filter
    direction    = var.direction_filter
  }
  depends_on = [
    google_cloud_ids_endpoint.ids_endpoint,
  ]
}
