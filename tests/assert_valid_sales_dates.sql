select
    sales_order_detail_id,
    order_date_key,
    ship_date_key
from {{ ref('fct_sales') }}
where ship_date_key is not null
  and ship_date_key < order_date_key