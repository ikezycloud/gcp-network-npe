locals {
  all_subnets = merge(
    { for k, v in google_compute_subnetwork.subnetwork : k => v },
    { for k, v in google_compute_subnetwork.proxy_only : k => v },
    { for k, v in google_compute_subnetwork.psc : k => v }
  )

  # note: all additive bindings share a single namespace for the key.
  # In other words, if you have multiple additive bindings with the
  # same name, only one will be used.

  subnets = merge(
    { for s in var.subnets : "${s.region}/${s.name}" => s },
  )
  subnets_proxy_only = merge(
    { for s in var.subnets_proxy_only : "${s.region}/${s.name}" => s },
  )
  subnets_private_nat = merge(
    { for s in var.subnets_private_nat : "${s.region}/${s.name}" => s },
  )
  subnets_psc = merge(
    { for s in var.subnets_psc : "${s.region}/${s.name}" => s },
  )
}

resource "google_compute_subnetwork" "subnetwork" {
  provider                         = google-beta
  for_each                         = local.subnets
  project                          = var.project_id
  network                          = var.network
  name                             = each.value.name
  region                           = each.value.region
  ip_cidr_range                    = each.value.ip_cidr_range
  allow_subnet_cidr_routes_overlap = each.value.allow_subnet_cidr_routes_overlap
  description = (
    each.value.description == null
    ? "Terraform-managed."
    : each.value.description
  )

  private_ip_google_access = true

  stack_type = (
    try(each.value.ipv6, null) != null ? "IPV4_IPV6" : "IPV4_ONLY"
  )
  ipv6_access_type = (
    try(each.value.ipv6, null) != null ? each.value.ipv6.access_type : null
  )
  private_ipv6_google_access       = try(each.value.ipv6.enable_private_access, null)
  send_secondary_ip_range_if_empty = true


  dynamic "secondary_ip_range" {
    for_each = each.value.secondary_ip_ranges == null ? {} : each.value.secondary_ip_ranges
    content {
      range_name    = secondary_ip_range.key
      ip_cidr_range = secondary_ip_range.value
    }
  }


  dynamic "log_config" {
    for_each = each.value.flow_logs_config != null ? [""] : []
    content {
      aggregation_interval = each.value.flow_logs_config.aggregation_interval
      filter_expr          = each.value.flow_logs_config.filter_expression
      flow_sampling        = each.value.flow_logs_config.flow_sampling
      metadata             = each.value.flow_logs_config.metadata
      metadata_fields = (
        each.value.flow_logs_config.metadata == "CUSTOM_METADATA"
        ? each.value.flow_logs_config.metadata_fields
        : null
      )
    }
  }
}

resource "google_compute_subnetwork" "proxy_only" {
  for_each      = local.subnets_proxy_only
  project       = var.project_id
  network       = var.network
  name          = each.value.name
  region        = each.value.region
  ip_cidr_range = each.value.ip_cidr_range
  description = coalesce(
    each.value.description,
    "Terraform-managed proxy-only subnet for Regional HTTPS, Internal HTTPS of Cross-Regional HTTPS Internal LB."
  )
  purpose = each.value.global ? "GLOBAL_MANAGED_PROXY" : "REGIONAL_MANAGED_PROXY"
  role    = each.value.active ? "ACTIVE" : "BACKUP"
}


resource "google_compute_subnetwork" "private_nat" {
  for_each      = local.subnets_private_nat
  project       = var.project_id
  network       = var.network
  name          = each.value.name
  region        = each.value.region
  ip_cidr_range = each.value.ip_cidr_range
  description = coalesce(
    each.value.description,
    "Terraform-managed private NAT subnet."
  )
  purpose = "PRIVATE_NAT"

  # Explicitly setting stack to IPV4_ONLY
  stack_type = "IPV4_ONLY"


  dynamic "log_config" {
    for_each = each.value.flow_logs_config != null ? [""] : []
    content {
      aggregation_interval = each.value.flow_logs_config.aggregation_interval
      filter_expr          = each.value.flow_logs_config.filter_expression
      flow_sampling        = each.value.flow_logs_config.flow_sampling
      metadata             = each.value.flow_logs_config.metadata
      metadata_fields = (
        each.value.flow_logs_config.metadata == "CUSTOM_METADATA"
        ? each.value.flow_logs_config.metadata_fields
        : null
      )
    }
  }
}


resource "google_compute_subnetwork" "psc" {
  for_each      = local.subnets_psc
  project       = var.project_id
  network       = var.network
  name          = each.value.name
  region        = each.value.region
  ip_cidr_range = each.value.ip_cidr_range
  description = coalesce(
    each.value.description,
    "Terraform-managed subnet for Private Service Connect (PSC NAT)."
  )
  purpose                  = "PRIVATE_SERVICE_CONNECT"
  private_ip_google_access = true
  dynamic "log_config" {
    for_each = each.value.flow_logs_config != null ? [""] : []
    content {
      aggregation_interval = each.value.flow_logs_config.aggregation_interval
      filter_expr          = each.value.flow_logs_config.filter_expression
      flow_sampling        = each.value.flow_logs_config.flow_sampling
      metadata             = each.value.flow_logs_config.metadata
      metadata_fields = (
        each.value.flow_logs_config.metadata == "CUSTOM_METADATA"
        ? each.value.flow_logs_config.metadata_fields
        : null
      )
    }
  }
}