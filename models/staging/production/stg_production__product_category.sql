with source as (
    select * from {{ source('raw_production', 'production_productcategory') }}
),

renamed as (
    select
        -- Chaves
        cast(ProductCategoryID as int)      as product_category_id,
        cast(rowguid as string)             as row_guid,

        -- Atributos
        cast(Name as string)                as category_name, -- Ex: 'Bikes', 'Components', 'Clothing', 'Accessories'

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;