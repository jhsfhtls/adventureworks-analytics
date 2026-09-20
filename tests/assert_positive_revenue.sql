select
    sales_order_detail_id,
    sales_order_id,
    gross_amount,
    net_amount
from {{ ref('fct_sales') }}
where net_amount < 0
   or gross_amount < 0