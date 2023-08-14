# Cloud IDS Terraform Module
This module makes it easy to setup [Cloud IDS](https://cloud.google.com/ids), set up [private services access](https://cloud.google.com/vpc/docs/private-services-access) and a [packet mirroring policy](https://cloud.google.com/vpc/docs/using-packet-mirroring).

The packet mirroring policy requires at least one of the three below options:
- [Tags](#pre_configured_rules): Up to 5 asset tags can be specified.
- [Subnets](#security_rules): Up to 5 subnets can be specified.
- [Instances](#custom_rules): Up to 50 instance can be specified.

##  Usage

```tf
module cloud_ids {
  source = "GoogleCloudPlatform/terraform-google-cloud-ids"

  project_id                          = "<PROJECT_ID>"
  vpc_network_name                    = "<VPC_NETWORK_NAME>"
  network_region                      = "<NETWORK_REGION>"
  network_zone                        = "<NETWORK_ZONE>"
  instance_list = [
    "projects/<PROJECT_ID>/zones/<ZONE-1>/instances/<INSTANCE-1>",
    "projects/<PROJECT_ID>/zones/<ZONE-2>/instances/<INSTANCE-2>",
  ]
  subnet_list = [
    "projects/<PROJECT_ID>/regions/<ZONE-1>/subnetworks/<SUBNETWORK-1>",
    "projects/<PROJECT_ID>/regions/<ZONE-1>/subnetworks/<SUBNETWORK-1>",
  ]
  tag_list = ["<TAG-1>", "<TAG-2>", "<TAG-3>", "<TAG-4>"]
  ids_private_ip_range_name           = "ids-private-address"
  ids_private_ip_address              = "10.10.10.0"
  ids_private_ip_prefix_length        = 24
  ids_private_ip_description          = "Cloud IDS reserved IP Range"
  ids_name                            = "cloud-ids"
  severity                            = "INFORMATIONAL"
  packet_mirroring_policy_name        = "cloud-ids-packet-mirroring"
  packet_mirroring_policy_description = "Packet mirroring policy for Cloud IDS"
}
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| cidr\_ranges\_filter | IP CIDR ranges that apply as a filter on the source (ingress) or destination (egress) IP in the IP header. Only IPv4 is supported. | `list(string)` | `[]` | no |
| direction\_filter | Direction of traffic to mirror. Possible values are INGRESS, EGRESS, and BOTH. | `string` | `"BOTH"` | no |
| ids\_name | Cloud IDS instance name | `string` | `"cloud-ids"` | no |
| ids\_private\_ip\_address | Cloud IDS private IP address | `string` | `"10.10.10.0"` | no |
| ids\_private\_ip\_description | Cloud IDS private IP address description | `string` | `"Cloud IDS reserved IP Range"` | no |
| ids\_private\_ip\_prefix\_length | Cloud IDS private IP address prefix length | `string` | `24` | no |
| ids\_private\_ip\_range\_name | Cloud IDS private IP address range name | `string` | `"ids-private-address"` | no |
| instance\_list | Instance list to monitor with Cloud IDS | `list(string)` | `null` | no |
| ip\_protocols\_filter | IP Protocols filter for packet mirroing policy. Can include 'tcp', 'udp', 'icmp', and 'esp' | `list(string)` | `[]` | no |
| network\_region | Network region for IDS | `string` | n/a | yes |
| network\_zone | Network zone for IDS | `string` | n/a | yes |
| packet\_mirroring\_policy\_description | Packet mirroring policy description | `string` | `"Packet mirroring policy for Cloud IDS"` | no |
| packet\_mirroring\_policy\_name | Packet mirroring policy name | `string` | `"cloud-ids-packet-mirroring"` | no |
| project\_id | Project ID to deploy resources | `string` | n/a | yes |
| severity | The minimum alert severity level that is reported by the endpoint | `string` | `"INFORMATIONAL"` | no |
| subnet\_list | Subnet list to monitor with Cloud IDS | `list(string)` | `null` | no |
| tag\_list | Tag list to monitor with Cloud IDS | `list(string)` | `null` | no |
| threat\_exceptions | Threat IDs excluded from generating alerts. Limit: 99 IDs. | `list(string)` | `[]` | no |
| vpc\_network\_name | VPC network name for IDS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ids\_endpoint\_id | IDS Endpoint id |
| ids\_endpoint\_severity | IDS Endpoint severity |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

## Requirements

These sections describe requirements for using this module.

### Software

The following dependencies must be available:

- [Terraform][terraform] v1.3
- [Terraform Provider for GCP][terraform-provider-gcp] plugin v3.53

### Service Account

A service account with the following roles must be used to provision
the resources of this module:

- Cloud IDS Admin: `roles/ids.admin`
- Compute Packet Mirroring User: `roles/compute.packetMirroringUser`
- Logs Viewer: `roles/logging.viewer`

The [Project Factory module][project-factory-module] and the
[IAM module][iam-module] may be used in combination to provision a
service account with the necessary roles applied.

### APIs

A project with the following APIs enabled must be used to host the
resources of this module:

- Cloud IDS API: `ids.googleapis.com`
- Cloud Logging API: `logging.googleapis.com`
- Compute Engine API: `compute.googleapis.com`
- Service Networking API: `servicenetworking.googleapis.com`

The [Project Factory module][project-factory-module] can be used to
provision a project with the necessary APIs enabled.

## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.
