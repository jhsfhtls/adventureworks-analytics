with source as (
    select * from {{ source('raw_person', 'person_personphone') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)       as business_entity_id,
        cast(PhoneNumberTypeID as int)      as phone_number_type_id,

        -- Contato telefônico
        cast(PhoneNumber as string)         as phone_number,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;