with source as (
    select * from {{ source('raw_sales', 'sales_salesorderheadersalesreason') }}
),

renamed as (
    select
        -- Chaves compostas
        cast(SalesOrderID as int)           as sales_order_id,
        cast(SalesReasonID as int)          as sales_reason_id,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;