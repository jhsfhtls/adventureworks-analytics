with source as (
    select * from {{ source('raw_person', 'person_addresstype') }}
),

renamed as (
    select
        -- Chaves
        cast(AddressTypeID as int)          as address_type_id,
        cast(rowguid as string)             as row_guid,

        -- Atributos
        cast(Name as string)                as address_type_name, -- Ex: 'Billing', 'Home', 'Main Office', 'Shipping'

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;