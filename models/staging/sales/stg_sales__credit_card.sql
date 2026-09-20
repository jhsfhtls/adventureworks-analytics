with source as (
    select * from {{ source('raw_sales', 'sales_creditcard') }}
),

renamed as (
    select
        -- Chaves
        cast(CreditCardID as int)           as credit_card_id,

        -- Dados do cartão
        cast(CardType as string)            as card_type, -- Ex: 'SuperiorCard', 'Distinguish', 'Vista'
        cast(CardNumber as string)          as card_number,
        cast(ExpMonth as int)               as expiration_month,
        cast(ExpYear as int)                as expiration_year,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;