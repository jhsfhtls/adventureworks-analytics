with source as (
    select * from {{ source('raw_person', 'person_businessentitycontact') }}
),

renamed as (
    select
        -- Chaves compostas e relacionamentos
        cast(BusinessEntityID as int)       as business_entity_id,
        cast(PersonID as int)               as person_id,
        cast(ContactTypeID as int)          as contact_type_id,
        cast(rowguid as string)             as row_guid,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;