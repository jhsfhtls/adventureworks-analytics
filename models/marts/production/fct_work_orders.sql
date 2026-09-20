with work_orders as (
    select * from {{ ref('int_work_orders_enriched') }}
),

final as (
    select
        -- Chave primária da ordem de produção
        work_order_id,

        -- Chaves estrangeiras de data
        cast(date_format(start_date, 'yyyyMMdd') as int)    as start_date_key,
        cast(date_format(end_date, 'yyyyMMdd') as int)      as end_date_key,
        cast(date_format(due_date, 'yyyyMMdd') as int)      as due_date_key,

        -- Chaves de produto e refugo
        product_id,
        coalesce(scrap_reason_id, -1)                       as scrap_reason_id,
        scrap_reason_name,

        -- Prazos e eficiência temporal
        production_cycle_days,
        is_produced_on_time,
        total_operations_count,

        -- Volumes e perdas de manufatura
        order_quantity,
        stocked_quantity,
        scrapped_quantity,
        scrap_rate_percentage,

        -- Horas fabris e custos (Orçado vs. Realizado)
        total_actual_resource_hours,
        total_planned_cost,
        total_actual_cost,
        cost_variance_amount                                -- Positivo indica estouro de custo; Negativo economia
    from work_orders
)

select * from final;