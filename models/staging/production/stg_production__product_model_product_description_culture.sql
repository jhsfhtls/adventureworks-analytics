with source as (
    select * from {{ source('raw_production', 'production_productmodelproductdescriptionculture') }}
),

renamed as (
    select
        -- Chaves compostas (relacionamento n:n de modelo, descrição e idioma)
        cast(ProductModelID as int)         as product_model_id,
        cast(ProductDescriptionID as int)   as product_description_id,
        cast(CultureID as string)           as culture_id,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;