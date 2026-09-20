with source as (
    select * from {{ source('raw_production', 'production_productsubcategory') }}
),

renamed as (
    select
        -- Chaves
        cast(ProductSubcategoryID as int)   as product_subcategory_id,
        cast(ProductCategoryID as int)      as product_category_id,
        cast(rowguid as string)             as row_guid,

        -- Atributos
        cast(Name as string)                as subcategory_name, -- Ex: 'Mountain Bikes', 'Helmets', 'Road Frames'

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;