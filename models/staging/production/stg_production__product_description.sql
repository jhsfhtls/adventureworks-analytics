with source as (
    select * from {{ source('raw_production', 'production_productdescription') }}
),

renamed as (
    select
        -- Chaves
        cast(ProductDescriptionID as int)   as product_description_id,
        cast(rowguid as string)             as row_guid,

        -- Conteúdo
        cast(Description as string)         as product_description,

        -- Auditoria (armazenado como string no raw)
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;