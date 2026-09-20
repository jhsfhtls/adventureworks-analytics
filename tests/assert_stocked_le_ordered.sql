select
    work_order_id,
    order_quantity,
    stocked_quantity,
    scrapped_quantity
from {{ ref('fct_work_orders') }}
where stocked_quantity > order_quantity
   or scrapped_quantity < 0