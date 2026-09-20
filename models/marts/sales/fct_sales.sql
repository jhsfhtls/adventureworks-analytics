with sales_lines as (
    select * from {{ ref('int_sales_order_lines_enriched') }}
),

final as (
    select
        -- Chaves substitutas e dimensões degeneradas
        sales_order_detail_id,
        sales_order_id,
        sales_order_number,

        -- Chaves estrangeiras de data (FKs para dim_dates)
        cast(date_format(order_date, 'yyyyMMdd') as int)    as order_date_key,
        cast(date_format(due_date, 'yyyyMMdd') as int)      as due_date_key,
        cast(date_format(ship_date, 'yyyyMMdd') as int)     as ship_date_key,

        -- Chaves estrangeiras de negócio (FKs para dimensões)
        product_id,
        customer_id,
        coalesce(sales_person_id, -1)                       as sales_person_id, -- -1 identifica venda direta online sem vendedor
        territory_id,
        bill_to_address_id,
        ship_to_address_id,
        ship_method_id,
        special_offer_id,

        -- Atributos de classificação e canal
        order_status_code,
        is_online_order,
        sales_channel,
        sales_reasons_list,

        -- Métricas financeiras e de volume
        order_quantity,
        unit_price,
        unit_price_discount,
        unit_standard_cost,
        gross_amount,
        discount_amount,
        net_amount,                                         -- Faturamento Líquido
        total_cost_amount,                                  -- CPV (Custo dos Produtos Vendidos)
        gross_profit_amount,                                -- Lucro Bruto
        gross_margin_percentage                             -- Margem Bruta (%)
    from sales_lines
)

select * from final;