with source as (
    select * from {{ source('raw_production', 'production_productproductphoto') }}
),

renamed as (
    select
        -- Chaves compostas
        cast(ProductID as int)              as product_id,
        cast(ProductPhotoID as int)         as product_photo_id,

        -- Flags
        cast(Primary as boolean)            as is_primary_photo,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;