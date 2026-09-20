with work_orders as (
    select * from {{ ref('stg_production__work_order') }}
),

routings as (
    -- Agrega as operações fabris ao nível da ordem de produção
    select
        work_order_id,
        count(distinct operation_sequence)          as total_operations_count,
        sum(actual_resource_hours)                  as total_actual_resource_hours,
        sum(planned_cost)                           as total_planned_cost,
        sum(actual_cost)                            as total_actual_cost
    from {{ ref('stg_production__work_order_routing') }}
    group by work_order_id
),

scrap_reasons as (
    select * from {{ ref('stg_production__scrap_reason') }}
),

joined as (
    select
        -- Chaves
        wo.work_order_id,
        wo.product_id,
        wo.scrap_reason_id,

        -- Quantidades produzidas e perdas
        wo.order_quantity,
        wo.stocked_quantity,
        wo.scrapped_quantity,
        case 
            when wo.order_quantity > 0 
            then cast(wo.scrapped_quantity as decimal(10, 4)) / wo.order_quantity 
            else 0.0 
        end as scrap_rate_percentage,

        -- Motivo da perda (se houver)
        coalesce(sr.scrap_reason_name, 'Sem Refugo') as scrap_reason_name,

        -- Cronograma e prazos
        wo.start_date,
        wo.end_date,
        wo.due_date,
        datediff(wo.end_date, wo.start_date)        as production_cycle_days,
        case 
            when wo.end_date <= wo.due_date then true 
            else false 
        end as is_produced_on_time,

        -- Métricas agregadas do roteamento
        r.total_operations_count,
        coalesce(r.total_actual_resource_hours, 0)  as total_actual_resource_hours,
        coalesce(r.total_planned_cost, 0)           as total_planned_cost,
        coalesce(r.total_actual_cost, 0)            as total_actual_cost,
        cast(coalesce(r.total_actual_cost, 0) - coalesce(r.total_planned_cost, 0) as decimal(18, 4)) as cost_variance_amount,

        -- Auditoria
        wo.modified_date
    from work_orders wo
    left join routings r
        on wo.work_order_id = r.work_order_id
    left join scrap_reasons sr
        on wo.scrap_reason_id = sr.scrap_reason_id
)

select * from joined