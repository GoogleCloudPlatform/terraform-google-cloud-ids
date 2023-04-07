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


variable "project_id" {
  type        = string
  description = "Project ID to deploy resources"
}


variable "vpc_network_name" {
  type        = string
  description = "VPC network name for IDS"
}

variable "network_region" {
  type        = string
  description = "Network region for IDS"
}

variable "network_zone" {
  type        = string
  description = "Network zone for IDS"
}

variable "instance_list" {
  type        = list(string)
  description = "Instance list to monitor with Cloud IDS"
  default     = null
}

variable "subnet_list" {
  type        = list(string)
  description = "Subnet list to monitor with Cloud IDS"
  default     = null
}


variable "tag_list" {
  type        = list(string)
  description = "Tag list to monitor with Cloud IDS"
  default     = null
}

variable "ids_private_ip_range_name" {
  type        = string
  description = "Cloud IDS private IP address range name"
  default     = "ids-private-address"
}

variable "ids_private_ip_address" {
  type        = string
  description = "Cloud IDS private IP address"
  default     = "10.10.10.0"
}

variable "ids_private_ip_prefix_length" {
  type        = string
  description = "Cloud IDS private IP address prefix length"
  default     = 24
}

variable "ids_private_ip_description" {
  type        = string
  description = "Cloud IDS private IP address description"
  default     = "Cloud IDS reserved IP Range"
}

variable "ids_name" {
  type        = string
  description = "Cloud IDS instance name"
  default     = "cloud-ids"
}

variable "severity" {
  type        = string
  description = "The minimum alert severity level that is reported by the endpoint"
  default     = "INFORMATIONAL"
}

variable "packet_mirroring_policy_name" {
  type        = string
  description = "Packet mirroring policy name"
  default     = "cloud-ids-packet-mirroring"
}

variable "packet_mirroring_policy_description" {
  type        = string
  description = "Packet mirroring policy description"
  default     = "Packet mirroring policy for Cloud IDS"
}
