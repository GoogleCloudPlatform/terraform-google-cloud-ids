

# Cloud IDS Terraform Module
This module makes it easy to setup [Cloud IDS](https://cloud.google.com/ids), set up private services access and a packet mirroring policy. The packet mirroring policy requires at least one of the three below options:
- [Tags](#pre_configured_rules): Up to 5 asset tags can be specified.
- [Subnets](#security_rules): Up to 5 subnets can be specified.
- [Instances](#custom_rules): Up to 50 instance can be specified.


## Compatibility

This module is meant for use with Terraform 1.3+ and tested using Terraform 1.3+. If you find incompatibilities using Terraform >=1.3, please open an issue.


##  Assumptions and Prerequisites
This module assumes that below mentioned prerequisites are in place before consuming the module.

- All required APIs are enabled in the GCP Project
    - servicenetworking.googleapis.com
    - ids.googleapis.com
    - logging.googleapis.com
    - compute.googleapis.com
- Permissions are available



##  Usage

```
module cloud_ids {
  source = "GoogleCloudPlatform/terraform-google-cloud-ids"

  project_id                          = "<PROJECT_ID>"
  vpc_network_name                    = "<VPC_NETWORK_NAME>"
  network_region                      = "<NETWORK_REGION>"
  network_zone                        = "<NETWORK_ZONE>"
  instance_list                       = "<INSTANCE_ID_LIST>" 
  subnet_list                         = "<SUBNET_ID_LIST>"
  tag_list                            = "<TAG_LIST>"
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


Format for instance_list (includes instance_id), subnet_list (includes subnet_id) and tag_list variables is defined here.

```
instance_list                       = [
    "projects/<PROJECT_ID>/zones/<ZONE-1>/instances/<INSTANCE-1>",
    "projects/<PROJECT_ID>/zones/<ZONE-2>/instances/<INSTANCE-2>",
  ] 

subnet_list                       = [
    "projects/<PROJECT_ID>/regions/<ZONE-1>/subnetworks/<SUBNETWORK-1>",
    "projects/<PROJECT_ID>/regions/<ZONE-1>/subnetworks/<SUBNETWORK-1>",
    ]

tag_list = ["<TAG-1>", "<TAG-2>", "<TAG-3>", "<TAG-4>"]
```


<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ids\_name | Cloud IDS instance name | `string` | `"cloud-ids"` | no |
| ids\_private\_ip\_address | Cloud IDS private IP address | `string` | `"10.10.10.0"` | no |
| ids\_private\_ip\_description | Cloud IDS private IP address description | `string` | `"Cloud IDS reserved IP Range"` | no |
| ids\_private\_ip\_prefix\_length | Cloud IDS private IP address prefix length | `string` | `24` | no |
| ids\_private\_ip\_range\_name | Cloud IDS private IP address range name | `string` | `"ids-private-address"` | no |
| instance\_list | Instance list to monitor with Cloud IDS | `list(string)` | `null` | no |
| network\_region | Network region for IDS | `string` | n/a | yes |
| network\_zone | Network zone for IDS | `string` | n/a | yes |
| packet\_mirroring\_policy\_description | Packet mirroring policy description | `string` | `"Packet mirroring policy for Cloud IDS"` | no |
| packet\_mirroring\_policy\_name | Packet mirroring policy name | `string` | `"cloud-ids-packet-mirroring"` | no |
| project\_id | Project ID to deploy resources | `string` | n/a | yes |
| severity | The minimum alert severity level that is reported by the endpoint | `string` | `"INFORMATIONAL"` | no |
| subnet\_list | Subnet list to monitor with Cloud IDS | `list(string)` | `null` | no |
| tag\_list | Tag list to monitor with Cloud IDS | `list(string)` | `null` | no |
| vpc\_network\_name | VPC network name for IDS | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| ids\_endpoint\_id | IDS Endpoint id |
| ids\_endpoint\_severity | IDS Endpoint severity |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->



## Contributing

Refer to the [contribution guidelines](./CONTRIBUTING.md) for
information on contributing to this module.
