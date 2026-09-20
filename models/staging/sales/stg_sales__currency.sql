with source as (
    select * from {{ source('raw_sales', 'sales_currency') }}
),

renamed as (
    select
        -- Chaves
        cast(CurrencyCode as string)        as currency_code, -- Ex: 'USD', 'BRL', 'EUR', 'CAD'

        -- Atributos
        cast(Name as string)                as currency_name,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;