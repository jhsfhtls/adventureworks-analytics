select
    purchase_order_detail_id,
    purchase_order_id,
    received_quantity,
    rejected_quantity
from {{ ref('fct_purchases') }}
where rejected_quantity > received_quantity