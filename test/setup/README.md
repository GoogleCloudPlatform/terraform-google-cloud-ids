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
| billing\_account | The billing account id associated with the project, e.g. XXXXXX-YYYYYY-ZZZZZZ | `any` | n/a | yes |
| folder\_id | The folder to deploy in | `any` | n/a | yes |
| org\_id | The numeric organization id | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| project\_id | n/a |
| sa\_key | n/a |

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
