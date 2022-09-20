terraform {
  required_providers {
    signalfx = {
      source  = "splunk-terraform/signalfx"
      version = "6.17.0" # if the version is not included, Terraform will use the latest.
    }
    dominos = {
      source  = "the-noid/dominos"
      version = "0.1.0"
    }
  }
}


provider "signalfx" {
  auth_token = var.signalfx_key
  api_url    = "https://api.${var.signalfx_realm}.signalfx.com"
}

# resource "signalfx_time_chart" "mychart0" {
#   name        = "CPU Utilization"
#   description = "Very cool chart"

#   program_text = <<-EOF
#     data("cpu.utilization", filter=filter('host', '*')).publish(label='CPU Utilization')
#     EOF
# }

# resource "signalfx_dashboard_group" "mydashgroup0" {
#   name        = "Workshop Group - ${var.username}"
#   description = "${var.username}'s Awesome Workshop Group"
# }

# resource "signalfx_dashboard" "mydashboard0" {
#   name            = "Workshop Dashboard - ${var.username}"
#   dashboard_group = signalfx_dashboard_group.mydashgroup0.id

#   chart {
#     chart_id = signalfx_time_chart.mychart0.id
#     width    = 12
#     height   = 1
#     row      = 0
#   }
# }

# resource "signalfx_event_feed_chart" "myeventfeed0" {
#   name        = "Workshop Event Feed - ${var.username}"
#   description = "Dominos Pizza Order"

#   program_text = <<-EOF
#     data('dominos_pizza_order', filter=filter('pizza_attributes', '*')).publish(label='Dominos Pizza Order')
#     EOF
# }

# # print URL to dashboard
# output "dashboard_group_URL" {
#   value = "https://app.${var.signalfx_realm}.signalfx.com/#/dashboard/${signalfx_dashboard.mydashboard0.id}"
# }
