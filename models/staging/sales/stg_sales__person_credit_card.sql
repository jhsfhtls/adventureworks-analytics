with source as (
    select * from {{ source('raw_sales', 'sales_personcreditcard') }}
),

renamed as (
    select
        -- Chaves compostas
        cast(BusinessEntityID as int)           as person_business_entity_id,
        cast(CreditCardID as int)               as credit_card_id,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;