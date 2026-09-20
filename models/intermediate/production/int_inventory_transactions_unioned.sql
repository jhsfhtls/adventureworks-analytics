with current_transactions as (
    select
        transaction_id,
        product_id,
        reference_order_id,
        reference_order_line_id,
        transaction_date,
        transaction_type_code,
        quantity,
        actual_cost,
        false as is_archived,
        modified_date
    from {{ ref('stg_production__transaction_history') }}
),

archived_transactions as (
    select
        transaction_id,
        product_id,
        reference_order_id,
        reference_order_line_id,
        transaction_date,
        transaction_type_code,
        quantity,
        actual_cost,
        true as is_archived,
        modified_date
    from {{ ref('stg_production__transaction_history_archive') }}
),

unioned as (
    select * from current_transactions
    union all
    select * from archived_transactions
),

transformed as (
    select
        transaction_id,
        product_id,
        reference_order_id,
        reference_order_line_id,
        transaction_date,
        transaction_type_code,
        case transaction_type_code
            when 'W' then 'Work Order (Produção)'
            when 'S' then 'Sales Order (Venda)'
            when 'P' then 'Purchase Order (Compra)'
            else 'Outro'
        end as transaction_type_description,
        quantity,
        actual_cost,
        cast(quantity * actual_cost as decimal(18, 4)) as total_transaction_cost,
        is_archived,
        modified_date
    from unioned
)

select * from transformed