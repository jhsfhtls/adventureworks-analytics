with source as (
    select * from {{ source('raw_sales', 'sales_specialoffer') }}
),

renamed as (
    select
        -- Chaves
        cast(SpecialOfferID as int)             as special_offer_id,
        cast(rowguid as string)                 as row_guid,

        -- Atributos e tipo de promoção
        cast(Description as string)             as offer_description,
        cast(DiscountPct as decimal(5, 4))      as discount_percentage,
        cast(Type as string)                    as discount_type,     -- Ex: 'Volume Discount', 'Discontinued Product'
        cast(Category as string)                as customer_category, -- Ex: 'Reseller', 'Customer'

        -- Período de vigência
        cast(StartDate as date)                 as start_date,
        cast(EndDate as date)                   as end_date,

        -- Regras de quantidade
        cast(MinQty as int)                     as min_quantity,
        cast(MaxQty as int)                     as max_quantity,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;