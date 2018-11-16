view: customer_orders {
  derived_table: {
    explore_source: orders {
      column: customer_id { field: orders.customer_id }
      column: lifetime_orders { field: orders.lifetime_orders }
    }
    datagroup_trigger: orders_datagroup
  }

  # Define your dimensions and measures here, like this:
  dimension: customer_id {
    description: "Unique ID for each user that has ordered"
    type: number
    sql: ${TABLE}.customer_id ;;
  }

  dimension: lifetime_orders {
    description: "The total number of orders for each user"
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  measure: total_lifetime_orders {
    description: "Use this for counting lifetime orders across many users"
    type: sum
    sql: ${lifetime_orders} ;;
  }
}
