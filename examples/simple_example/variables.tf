/**
 * Copyright 2021 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

##  This code creates PoC example for Cloud IDS ##
##  It is not developed for production workload ##


variable "project_id" {
  type        = string
  description = "Project ID to deploy resources"
}


variable "vpc_network_name" {
  type        = string
  description = "VPC network name for IDS"
  default     = "cloud-ids-vpc"
}

variable "network_region" {
  type        = string
  description = "Network region for IDS"
  default     = "us-east1"

}

variable "network_zone" {
  type        = string
  description = "Network zone for IDS"
  default     = "us-east1-b"

}
