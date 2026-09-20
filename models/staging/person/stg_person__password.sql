with source as (
    select * from {{ source('raw_person', 'person_password') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)       as business_entity_id,
        cast(rowguid as string)             as row_guid,

        -- Credenciais (Hashes)
        cast(PasswordHash as string)        as password_hash,
        cast(PasswordSalt as string)        as password_salt,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;