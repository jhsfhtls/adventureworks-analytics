with source as (
    select * from {{ source('raw_person', 'person_businessentityaddress') }}
),

renamed as (
    select
        -- Chaves compostas e relacionamentos
        cast(BusinessEntityID as int)       as business_entity_id,
        cast(AddressID as int)              as address_id,
        cast(AddressTypeID as int)          as address_type_id,
        cast(rowguid as string)             as row_guid,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;