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

output "ids_endpoint_id" {
  description = "IDS Endpoint id"
  value       = module.cloud_ids.ids_endpoint_id
}

output "ids_endpoint_severity" {
  description = "IDS Endpoint severity"
  value       = module.cloud_ids.ids_endpoint_severity
}

output "ids_malicious_attacker_server" {
  value = "IDS attacker server ip - ${google_compute_instance.ids_attacker_machine.network_interface[0].network_ip}"

}

output "ids_victim_server_ip" {
  value = "IDS victim server ip - ${google_compute_instance.ids_victim_server.network_interface[0].network_ip}"

}

