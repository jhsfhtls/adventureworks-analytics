with source as (
    select * from {{ source('raw_person', 'person_stateprovince') }}
),

renamed as (
    select
        -- Chaves e relacionamentos
        cast(StateProvinceID as int)            as state_province_id,
        cast(CountryRegionCode as string)       as country_region_code,
        cast(TerritoryID as int)                as territory_id,
        cast(rowguid as string)                 as row_guid,

        -- Dados geográficos
        cast(StateProvinceCode as string)       as state_province_code,
        cast(Name as string)                    as state_province_name,
        cast(IsOnlyStateProvinceFlag as boolean) as is_only_state_province,

        -- Auditoria
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;