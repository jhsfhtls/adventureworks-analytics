with source as (
    select * from {{ source('raw_person', 'person_address') }}
),

renamed as (
    select
        -- Chaves
        cast(AddressID as int)              as address_id,
        cast(StateProvinceID as int)        as state_province_id,
        cast(rowguid as string)             as row_guid,

        -- Endereço
        cast(AddressLine1 as string)        as address_line_1,
        cast(AddressLine2 as string)        as address_line_2,
        cast(City as string)                as city_name,
        cast(PostalCode as string)          as postal_code,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;