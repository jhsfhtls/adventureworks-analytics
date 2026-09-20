with source as (
    select * from {{ source('raw_person', 'person_countryregion') }}
),

renamed as (
    select
        -- Chaves
        cast(CountryRegionCode as string)   as country_region_code, -- Ex: 'US', 'BR', 'CA'

        -- Atributos
        cast(Name as string)                as country_region_name,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;