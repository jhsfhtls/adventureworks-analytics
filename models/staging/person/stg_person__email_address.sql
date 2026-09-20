with source as (
    select * from {{ source('raw_person', 'person_emailaddress') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)       as business_entity_id,
        cast(EmailAddressID as int)         as email_address_id,
        cast(rowguid as string)             as row_guid,

        -- Contato
        cast(EmailAddress as string)        as email_address,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;