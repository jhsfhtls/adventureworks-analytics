with source as (
    select * from {{ source('raw_sales', 'sales_shoppingcartitem') }}
),

renamed as (
    select
        -- Chaves
        cast(ShoppingCartItemID as int)         as shopping_cart_item_id,
        cast(ShoppingCartID as int)             as shopping_cart_id,
        cast(ProductID as int)                  as product_id,

        -- Quantidade
        cast(Quantity as int)                   as quantity,

        -- Auditoria e criação
        cast(DateCreated as timestamp)          as created_at,
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;