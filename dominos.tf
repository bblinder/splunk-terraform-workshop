# terraform {
#   required_version = ">= 0.12.0"
#   required_providers {
#     dominos = {
#       source = "the-noid/dominos"
#       version = "0.1.0"
#     }
#   }
# }

variable "first_name" {
  description = "first name"
}

variable "last_name" {
  description = "last name"
}

variable "email" {
  description = "email"
}

variable "phone" {
  description = "phone"
}

variable "card_number" {
  description = "credit card number"
}

variable "card_cvv" {
  description = "cvv"
}

variable "card_expiration_date" {
  description = "expiration date"
}

variable "card_zip_code" {
  description = "zip code"
}

variable "store_street" {
  description = "store street"
}

variable "store_city" {
  description = "store city"
}

variable "store_state" {
  description = "store state"
}

variable "store_zip_code" {
  description = "store zip code"
}

variable "pizza_attributes" {
  description = "attributes of the pizzas to order"
  type        = list(list(string))
}

# variable "drink_attributes" {
#   description = "attributes of the drinks to order"
#   type        = list(list(string))
# }

provider "dominos" {
  first_name    = var.first_name
  last_name     = var.last_name
  email_address = var.email
  phone_number  = var.phone

  credit_card {
    number = var.card_number
    cvv    = var.card_cvv
    date   = var.card_expiration_date
    zip    = var.card_zip_code
  }
}

data "dominos_address" "addr" {
  street = var.store_street
  city   = var.store_city
  state  = var.store_state
  zip    = var.store_zip_code
}

data "dominos_store" "store" {
  address_url_object = data.dominos_address.addr.url_object
}

data "dominos_menu_item" "pizzas" {
  count        = length(var.pizza_attributes)
  store_id     = data.dominos_store.store.store_id
  query_string = var.pizza_attributes[count.index]
}

# data "dominos_menu_item" "drinks" {
#   count        = length(var.drink_attributes)
#   store_id     = data.dominos_store.store.store_id
#   query_string = var.drink_attributes[count.index]
# }

resource "dominos_order" "order" {
  address_api_object = data.dominos_address.addr.api_object
  #item_codes         = concat(data.dominos_menu_item.pizzas[*].matches[0].code, data.dominos_menu_item.drinks[*].matches[0].code)
  item_codes = concat(data.dominos_menu_item.pizzas[*].matches[0].code)
  store_id   = data.dominos_store.store.store_id
  depends_on = [signalfx_dashboard_group.mydashgroup0, signalfx_dashboard.mydashboard0, signalfx_time_chart.mychart0, signalfx_event_feed_chart.myeventfeed0]
}


output "pizzas" {
  value = [
    for pizza in data.dominos_menu_item.pizzas :
    {
      name        = pizza.matches[0].name
      code        = pizza.matches[0].code
      price_cents = pizza.matches[0].price_cents
    }
  ]
}

# output "drinks" {
#   value = [
#     for drink in data.dominos_menu_item.drinks :
#     {
#       name        = drink.matches[0].name
#       code        = drink.matches[0].code
#       price_cents = drink.matches[0].price_cents
#     }
#   ]
# }

# CURL command to send pizza attributes as custom event to Splunk API.
resource "null_resource" "eventfeed" {
  provisioner "local-exec" {
    command = <<-EOF
    curl -L -X POST 'https://ingest.${var.signalfx_realm}.signalfx.com/v2/event' \
      -H 'X-SF-TOKEN: ${var.signalfx_key}' \
      -H 'Content-Type: application/json' \
      --data-raw '[{
        "category": "USER_DEFINED",
        "eventType": "dominos_pizza_order: ${var.pizza_attributes}",
        "dimensions": {
          "feed": "dominos"
        }
    }]'
    EOF
  }
}