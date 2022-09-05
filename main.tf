terraform {
  required_providers {
    signalfx = {
      source  = "splunk-terraform/signalfx"
      version = "6.16.0"
    }
  }
}


provider "signalfx" {
  auth_token = var.signalfx_key
  api_url    = "https://api.${var.signalfx_realm}.signalfx.com"
}

resource "signalfx_time_chart" "mychart0" {
  name        = "CPU Utlization"
  description = "Very cool chart"

  program_text = <<-EOF
    data("cpu.utilization", filter=filter('host', '*')).publish(label='CPU Utilization')
    EOF
}

resource "signalfx_dashboard_group" "mydashgroup0" {
  name        = "Workshop Group - ${var.username}"
  description = "${var.username}'s Awesome Workshop Group"
}

resource "signalfx_dashboard" "mydashboard0" {
  name            = "Workshop Dashboard - ${var.username}"
  dashboard_group = signalfx_dashboard_group.mydashgroup0.id

  chart {
    chart_id = signalfx_time_chart.mychart0.id
    width    = 12
    height   = 1
    row      = 0
  }
}

# print URL to dashboard
output "dashboard_group_URL" {
  value = "https://app.${var.signalfx_realm}.signalfx.com/#/dashboard/${signalfx_dashboard.mydashboard0.id}"
}
