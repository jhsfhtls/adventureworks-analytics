with purchase_lines as (
    select * from {{ ref('int_purchase_order_lines_enriched') }}
),

final as (
    select
        -- Chaves da compra
        purchase_order_detail_id,
        purchase_order_id,

        -- Chaves de data
        cast(date_format(order_date, 'yyyyMMdd') as int)    as order_date_key,
        cast(date_format(ship_date, 'yyyyMMdd') as int)     as ship_date_key,
        cast(date_format(due_date, 'yyyyMMdd') as int)      as due_date_key,

        -- Chaves de relacionamento
        vendor_business_entity_id                           as vendor_id,
        product_id,
        buyer_employee_id,
        ship_method_id,

        -- Indicadores de entrega e status
        order_status_code,
        order_status_description,
        is_delivered_on_time,                               -- Aderência ao prazo (OTIF)

        -- Volumes e conferência de qualidade
        order_quantity,
        received_quantity,
        rejected_quantity,
        stocked_quantity,
        rejection_rate_percentage,                          -- Taxa de Não Conformidade (%)

        -- Valores financeiros
        unit_price,
        line_subtotal_amount                                -- Total Comprado (R$)
    from purchase_lines
)

select * from final;