with source as (
    select * from {{ source('raw_sales', 'sales_salestaxrate') }}
),

renamed as (
    select
        -- Chaves e relacionamentos
        cast(SalesTaxRateID as int)         as sales_tax_rate_id,
        cast(StateProvinceID as int)        as state_province_id,
        cast(rowguid as string)             as row_guid,

        -- Configurações tributárias
        cast(TaxType as int)                as tax_type_code, -- 1 = State tax, 2 = County tax, 3 = City tax
        cast(TaxRate as decimal(7, 4))      as tax_rate_percentage,
        cast(Name as string)                as tax_rate_name,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;