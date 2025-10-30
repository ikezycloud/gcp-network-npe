locals {

  all_subnets_properties = [
    { subnetwork : { for k, v in google_compute_subnetwork.subnetwork : k => v } },
    { proxy_only : { for k, v in google_compute_subnetwork.proxy_only : k => v } },
    { psc : { for k, v in google_compute_subnetwork.psc : k => v } },
    { private_nat : { for k, v in google_compute_subnetwork.private_nat : k => v } }
  ]
}

output "subnets_properties" {
  description = "This outputs a list of dictionaries of subnets and their information for export to Infoblox NIOS"
  value       = local.all_subnets_properties
}

output "subnetwork_attributes" {
  description = "Details of configured subnetworks"
  value = [for subnet in merge(googoogle_compute_subnetwork.subnetwork, googoogle_compute_subnetwork.proxy_only, googoogle_compute_subnetwork.private_nat, googoogle_compute_subnetwork.psc) :
    {
      name        = subnet.name
      description = subnet.description
      id          = subnet.id
      self_link   = subnet.self_link
      cidr        = subnet.ip_cidr_range
      gateway     = subnet.gateway_address
      network     = subnet.network
    }
  ]
}

output "subnet_self_link" {
  value = {
    for key, subnet in googoogle_compute_subnetwork.private_nat : key => subnet.self_link # Displays all self links from all private nat resources.
  }
}