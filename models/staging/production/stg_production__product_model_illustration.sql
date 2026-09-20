with source as (
    select * from {{ source('raw_production', 'production_productmodelillustration') }}
),

renamed as (
    select
        -- Chaves compostas
        cast(ProductModelID as int)         as product_model_id,
        cast(IllustrationID as int)         as illustration_id,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;