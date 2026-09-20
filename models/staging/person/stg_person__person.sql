with source as (
    select * from {{ source('raw_person', 'person_person') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)       as business_entity_id,
        cast(rowguid as string)             as row_guid,

        -- Classificação
        cast(PersonType as string)          as person_type_code, -- 'EM' (Employee), 'SC' (Store Contact), 'IN' (Individual Customer), etc.

        -- Nome completo e tratamento
        cast(NameStyle as boolean)          as is_western_name_style,
        cast(Title as string)               as title_name,
        cast(FirstName as string)           as first_name,
        cast(MiddleName as string)          as middle_name,
        cast(LastName as string)            as last_name,
        cast(Suffix as string)              as suffix_name,

        -- Preferências e Metadados adicionais
        cast(EmailPromotion as int)         as email_promotion_preference, -- 0 = Não contatar, 1 = Apenas AW, 2 = Parceiros
        cast(AdditionalContactInfo as string) as additional_contact_info_xml,
        cast(Demographics as string)        as demographics_xml,

        -- Auditoria (armazenado como string no raw)
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;