with source as (
    select * from {{ source('raw_production', 'production_productdocument') }}
),

renamed as (
    select
        -- Chaves e relacionamentos
        cast(ProductID as int)              as product_id,
        cast(DocumentNode as string)        as document_node,

        -- Auditoria
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;