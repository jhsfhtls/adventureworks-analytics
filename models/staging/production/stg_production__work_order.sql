with source as (
    select * from {{ source('raw_production', 'production_workorder') }}
),

renamed as (
    select
        -- Chaves
        cast(WorkOrderID as int)        as work_order_id,
        cast(ProductID as int)          as product_id,
        cast(ScrapReasonID as int)      as scrap_reason_id,

        -- Quantidades da ordem
        cast(OrderQty as int)           as order_quantity,
        cast(StockedQty as int)         as stocked_quantity,
        cast(ScrappedQty as int)        as scrapped_quantity,

        -- Prazos e execução
        cast(StartDate as date)         as start_date,
        cast(EndDate as date)           as end_date,
        cast(DueDate as date)           as due_date,

        -- Auditoria
        cast(ModifiedDate as date)      as modified_date
    from source
)

select * from renamed;