resource "google_compute_network" "network" {
  project                                   = var.project_id
  name                                      = var.name
  description                               = var.description
  auto_create_subnetworks                   = var.auto_create_subnetworks
  delete_default_routes_on_create           = var.delete_default_routes_on_create
  mtu                                       = var.mtu
  routing_mode                              = var.routing_mode
  network_firewall_policy_enforcement_order = var.firewall_policy_enforcement_order
  enable_ula_internal_ipv6                  = var.ipv6_config.enable_ula_internal
  internal_ipv6_range                       = var.ipv6_config.internal_range
}