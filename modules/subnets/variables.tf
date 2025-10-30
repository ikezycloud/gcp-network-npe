variable "project_id" {
  description = "The ID of the project where this VPC will be created"
  type        = string
  default     = "gcp3-core-net-npe-1234"
}

variable "network" {
  description = "Network name"
  type        = string
  default     = "network_test"
}

variable "network_name" {
  description = "Network name"
  type        = string
  default     = "network_test"
}

variable "psa_configs" {
  description = "The Private Service Access configuration"
  type = list(object({
    deletion_policy  = optional(string, null)
    ranges           = map(string)
    export_routes    = optional(bool, false)
    import_routes    = optional(bool, false)
    peered_domains   = optional(list(string), [])
    range_prefix     = optional(string)
    service_producer = optional(string, "servicenetworking.googleapis.com")
  }))
  nullable = false
  default  = []
  validation {
    condition = (
      length(var.psa_configs) == length(toset([
        for v in var.psa_configs : v.service_producer
      ]))
    )
    error_message = "At most one configuration is possible for each service producer."
  }
  validation {
    condition = alltrue([
      for v in var.psa_configs : (
        v.deletion_policy == null || v.deletion_policy == "ABANDON"
      )
    ])
    error_message = "Deletion policy supports only ABANDON."
  }
}

variable "subnets" {
  description = "Subnet Configuration"
  type = list(object({
    name                             = string
    ip_cidr_range                    = string
    region                           = string
    description                      = optional(string)
    enable_private_access            = optional(bool, true)
    allow_subnet_cidr_routes_overlap = optional(bool, null)
    flow_logs_config = optional(object({
      aggregation_interval = optional(string, "INTERVAL_5_MIN")
      filter_expression    = optional(string, true)
      flow_sampling        = optional(number, 1)
      metadata             = optional(string, "INCLUDE_ALL_METADATA")
      # only if metadata == "CUSTOM_METADATA"
      metadata_fields = optional(list(string), [])
    }))
    ipv6 = optional(object({
      access_type = optional(string, "INTERNAL")
      # this field is marked for internal use in the API documentation
      # enable_private_access = optional(string)
    }))
    secondary_ip_ranges = optional(map(string))
    iam                 = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      role    = string
      members = list(string)
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    iam_bindings_additive = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
  }))
  default  = []
  nullable = false
}

variable "subnets_private_nat" {
  description = "List of private NAT subnets."
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    description   = optional(string)
    flow_logs_config = optional(object({
      aggregation_interval = optional(string, "INTERVAL_5_MIN")
      filter_expression    = optional(string, true)
      flow_sampling        = optional(number, 1)
      metadata             = optional(string, "INCLUDE_ALL_METADATA")
      # only if metadata == "CUSTOM_METADATA"
      metadata_fields = optional(list(string), [])
    }))
  }))
  default  = []
  nullable = false
}

variable "subnets_proxy_only" {
  description = "List of proxy-only subnets for Regional HTTPS or Internal HTTPS load balancers. Note: Only one proxy-only subnet for each VPC network in each region can be active"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    description   = optional(string)
    active        = optional(bool, true)
    global        = optional(bool, false)
    iam           = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      role    = string
      members = list(string)
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    iam_bindings_additive = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
  }))
  default  = []
  nullable = false
}

variable "subnets_psc" {
  description = "List of subnets for Private Service Connect service producers"
  type = list(object({
    name          = string
    ip_cidr_range = string
    region        = string
    description   = optional(string)

    iam = optional(map(list(string)), {})
    iam_bindings = optional(map(object({
      role    = string
      members = list(string)
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    iam_bindings_additive = optional(map(object({
      member = string
      role   = string
      condition = optional(object({
        expression  = string
        title       = string
        description = optional(string)
      }))
    })), {})
    flow_logs_config = optional(object({
      aggregation_interval = optional(string, "INTERVAL_5_MIN")
      filter_expression    = optional(string, true)
      flow_sampling        = optional(number, 1)
      metadata             = optional(string, "INCLUDE_ALL_METADATA")
      # only if metadata == "CUSTOM_METADATA"
      metadata_fields = optional(list(string), [])
    }))
  }))
  default  = []
  nullable = false
}