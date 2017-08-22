view: order_items {
  sql_table_name: demo_db.order_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.order_id ;;
  }

  dimension: profit_tier {
    case: {
      when: {
        sql: ${profit_percentage} < 0 ;;
        label: "loss"
      }
      when: {
        sql: ${profit_percentage} < .25 ;;
        label: "low"
      }
      when: {
        sql: ${profit_percentage} < 1 ;;
        label: "mid"
      }
      when: {
        sql: ${profit_percentage} < 1.5 ;;
        label: "high"
      }
      else: "very high"
    }
  }

  dimension_group: returned {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.returned_at ;;
  }

  dimension: returned {
    type: yesno
    sql: ${returned_date} ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: profit {
    type: number
    sql: ${order_items.sale_price} - ${inventory_items.cost} ;;
    value_format: "$0.00"
  }

  dimension: profit_percentage {
    type: number
    hidden: yes
    sql: (${order_items.sale_price} - ${inventory_items.cost}) /  ${inventory_items.cost};;
    value_format: "0.00%"
  }

  set: order_item_details {
    fields: [order_id, users.id, count, total_profit, gross_revenue ]
  }

  measure: count {
    type: count
    drill_fields: [id, inventory_items.id, orders.id]
  }

  measure: average_profit {
    view_label: "Order Facts"
    type: average
    sql: ${profit} ;;
    value_format: "$0.00"
    drill_fields: [order_item_details*]
  }

  measure: total_profit {
    view_label: "Order Facts"
    type: sum
    sql: ${profit} ;;
    value_format: "$#,##0.00"
    drill_fields: [order_item_details*]
  }

  measure: gross_revenue {
    description: "Sum of item sales, not including returned items"
    view_label: "Order Facts"
    type: sum
    sql: ${sale_price} ;;
    value_format: "$#,##0.00"
    filters: {
      field: order_items.returned
      value: "no"
    }
    drill_fields: [order_item_details*]
  }
  measure: gross_margin {
    view_label: "Order Facts"
    type: number
    sql: ${gross_revenue} / ${total_profit} ;;
    value_format_name: percent_1
  }
}
