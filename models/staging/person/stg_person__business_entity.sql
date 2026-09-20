with source as (
    select * from {{ source('raw_person', 'person_businessentity') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)       as business_entity_id,
        cast(rowguid as string)             as row_guid,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;