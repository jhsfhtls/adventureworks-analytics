with source as (
    select * from {{ source('raw_sales', 'sales_salesreason') }}
),

renamed as (
    select
        -- Chaves
        cast(SalesReasonID as int)          as sales_reason_id,

        -- Atributos
        cast(Name as string)                as sales_reason_name, -- Ex: 'Price', 'Promotion', 'Manufacturer', 'Review'
        cast(ReasonType as string)          as sales_reason_type, -- Ex: 'Marketing', 'Other'

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;