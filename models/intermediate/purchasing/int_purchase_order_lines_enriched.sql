with details as (
    select * from {{ ref('stg_purchasing__purchase_order_detail') }}
),

headers as (
    select * from {{ ref('stg_purchasing__purchase_order_header') }}
),

vendors as (
    select * from {{ ref('int_vendors_enriched') }}
),

ship_methods as (
    select * from {{ ref('stg_purchasing__ship_method') }}
),

joined as (
    select
        -- Chaves
        d.purchase_order_detail_id,
        d.purchase_order_id,
        d.product_id,
        h.vendor_business_entity_id,
        h.buyer_employee_id,
        h.ship_method_id,

        -- Fornecedor e frete
        v.vendor_name,
        v.credit_rating,
        sm.ship_method_name,

        -- Datas e ciclo de compras
        h.order_date,
        h.ship_date,
        d.due_date,
        case 
            when h.ship_date <= d.due_date then true 
            else false 
        end as is_delivered_on_time,

        -- Status do pedido de compra
        h.order_status_code,
        case h.order_status_code
            when 1 then 'Pendente'
            when 2 then 'Aprovado'
            when 3 then 'Rejeitado'
            when 4 then 'Concluído'
            else 'Outro'
        end as order_status_description,

        -- Quantidades físicas e conferência
        d.order_quantity,
        d.received_quantity,
        d.rejected_quantity,
        d.stocked_quantity,
        case 
            when d.order_quantity > 0 
            then cast(d.rejected_quantity as decimal(10, 4)) / d.order_quantity 
            else 0.0 
        end as rejection_rate_percentage,

        -- Valores financeiros
        d.unit_price,
        d.line_total as line_subtotal_amount,

        -- Auditoria
        d.modified_at
    from details d
    inner join headers h
        on d.purchase_order_id = h.purchase_order_id
    left join vendors v
        on h.vendor_business_entity_id = v.vendor_business_entity_id
    left join ship_methods sm
        on h.ship_method_id = sm.ship_method_id
)

select * from joined