with details as (
    select * from {{ ref('stg_sales__sales_order_detail') }}
),

headers as (
    select * from {{ ref('stg_sales__sales_order_header') }}
),

products as (
    select * from {{ ref('int_products_enriched') }}
),

reasons as (
    select * from {{ ref('int_sales_order_reasons_aggregated') }}
),

joined as (
    select
        -- Chaves
        d.sales_order_detail_id,
        d.sales_order_id,
        d.product_id,
        h.customer_id,
        h.sales_person_id,
        h.territory_id,
        h.bill_to_address_id,
        h.ship_to_address_id,
        h.ship_method_id,
        d.special_offer_id,

        -- Identificadores e status
        h.sales_order_number,
        h.order_status_code,
        h.is_online_order,
        case 
            when h.is_online_order then 'Digital (E-commerce)'
            else 'Físico / Revenda'
        end as sales_channel,

        -- Datas
        h.order_date,
        h.due_date,
        h.ship_date,

        -- Motivos de compra agregados (sem fan-out)
        coalesce(r.sales_reasons_list, 'Não Informado') as sales_reasons_list,

        -- Quantidade e preços
        d.order_quantity,
        d.unit_price,
        d.unit_price_discount,
        p.standard_cost                                 as unit_standard_cost,

        -- Cálculos financeiros no grão do item
        cast(d.order_quantity * d.unit_price as decimal(18, 4)) as gross_amount,
        cast((d.order_quantity * d.unit_price) * d.unit_price_discount as decimal(18, 4)) as discount_amount,
        cast(d.line_total_amount as decimal(18, 4))     as net_amount,
        cast(d.order_quantity * p.standard_cost as decimal(18, 4)) as total_cost_amount,
        cast(d.line_total_amount - (d.order_quantity * p.standard_cost) as decimal(18, 4)) as gross_profit_amount,
        case 
            when d.line_total_amount > 0 
            then cast((d.line_total_amount - (d.order_quantity * p.standard_cost)) / d.line_total_amount as decimal(10, 4))
            else 0.0 
        end as gross_margin_percentage,

        -- Auditoria
        d.modified_date
    from details d
    inner join headers h
        on d.sales_order_id = h.sales_order_id
    left join products p
        on d.product_id = p.product_id
    left join reasons r
        on d.sales_order_id = r.sales_order_id
)

select * from joined