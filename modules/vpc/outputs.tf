output "vpc_id" {
  description = "Identifies the VPC"
  value = google_compute_network.network.id
}

output "vpc_gateway_ipv4" {
  description = "This is the IPV4 address of the VPC gateway"
  value = google_compute_network.network.gateway_ipv4
}

output "vpc_self_link_url" {
  description = "The URI of the created VPC resource"
  value = google_compute_network.network.self_link
}