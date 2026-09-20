with source as (
    select * from {{ source('raw_sales', 'sales_specialofferproduct') }}
),

renamed as (
    select
        -- Chaves compostas (associação N:N de promoções e produtos)
        cast(SpecialOfferID as int)             as special_offer_id,
        cast(ProductID as int)                  as product_id,
        cast(rowguid as string)                 as row_guid,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;