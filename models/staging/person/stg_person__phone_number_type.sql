with source as (
    select * from {{ source('raw_person', 'person_phonenumbertype') }}
),

renamed as (
    select
        -- Chaves
        cast(PhoneNumberTypeID as int)      as phone_number_type_id,

        -- Atributos
        cast(Name as string)                as phone_number_type_name, -- 'Cell', 'Home', 'Work'

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;