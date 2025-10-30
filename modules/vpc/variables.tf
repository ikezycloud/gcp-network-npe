variable "auto_create_subnetworks" {
  description = "Set to true to create an auto mode subnet, defaults to custom mode"
  type        = bool
  default     = false
}

variable "delete_default_routes_on_create" {
  description = "Set to true to delete default routes at creation time"
  type        = bool
  default     = false
}

variable "description" {
  description = "An optional description of this resource (triggers recreation on change)"
  type        = string
  default     = "Terrafrom managed"
}

variable "firewall_policy_enforcement_order" {
  description = "Order that Firewall Rules and Firewall Policies are evaluated. Can be either 'BEFORE_CLASSIC_FIREWALL' or 'AFTER_CLASSIC_FIREWALL'."
  type        = string
  nullable    = false
  default     = "AFTER_CLASSIC_FIREWALL"

  validation {
    condition     = var.firewall_policy_enforcement_order == "BEFORE_CLASSIC_FIREWALL" || var.firewall_policy_enforcement_order == "AFTER_CLASSIC_FIREWALL"
    error_message = "Enforcement order must be BEFORE_CLASSIC_FIREWALL or AFTER_CLASSIC_FIREWALL"
  }
}

variable "ipv6_config" {
  description = "Optional IPv6 configuration for this network"
  type = object({
    enable_ula_internal = optional(bool)
    internal_range      = optional(string)
  })
  nullable = false
  default  = {}
}

variable "mtu" {
  description = "Maximum Transmission Unit in bytes. 1460 minimum & 1500 bytes maximum"
  type        = number
  default     = null
}

variable "name" {
  description = "The name of the network"
  type        = string
}

variable "project_id" {
  description = "The ID of the project where this VPC will be created"
  type        = string
}

variable "routing_mode" {
  description = "The network routing mode (default 'GLOBAL')"
  type        = string
  default     = "GLOBAL"
  validation {
    condition     = var.routing_mode == "GLOBAL" || var.routing_mode == "REGIONAL"
    error_message = "Routing type must be GLOBAL or REGIONAL."
  }
}