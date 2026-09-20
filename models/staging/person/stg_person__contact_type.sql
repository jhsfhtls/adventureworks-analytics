with source as (
    select * from {{ source('raw_person', 'person_contacttype') }}
),

renamed as (
    select
        -- Chaves
        cast(ContactTypeID as int)          as contact_type_id,

        -- Atributos
        cast(Name as string)                as contact_type_name, -- Ex: 'Accounting Manager', 'Purchasing Agent'

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;