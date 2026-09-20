with source as (
    select * from {{ source('raw_production', 'production_workorderrouting') }}
),

renamed as (
    select
        -- Chaves compostas e relacionamentos
        cast(WorkOrderID as int)                as work_order_id,
        cast(ProductID as int)                  as product_id,
        cast(OperationSequence as int)          as operation_sequence,
        cast(LocationID as int)                 as location_id,

        -- Cronograma e execução
        cast(ScheduledStartDate as date)        as scheduled_start_date,
        cast(ScheduledEndDate as date)          as scheduled_end_date,
        cast(ActualStartDate as date)           as actual_start_date,
        cast(ActualEndDate as date)             as actual_end_date,

        -- Recursos e custos
        cast(ActualResourceHrs as decimal(10, 4)) as actual_resource_hours,
        cast(PlannedCost as decimal(18, 4))     as planned_cost,
        cast(ActualCost as decimal(18, 4))      as actual_cost,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;