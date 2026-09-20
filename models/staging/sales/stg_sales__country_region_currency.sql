with source as (
    select * from {{ source('raw_sales', 'sales_countryregioncurrency') }}
),

renamed as (
    select
        -- Chaves compostas
        cast(CountryRegionCode as string)   as country_region_code,
        cast(CurrencyCode as string)        as currency_code,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;