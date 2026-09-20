with source as (
    select * from {{ source('raw_production', 'production_productphoto') }}
),

renamed as (
    select
        -- Chaves
        cast(ProductPhotoID as int)                 as product_photo_id,

        -- Arquivos e imagens (binários/strings codificadas)
        cast(ThumbNailPhoto as string)              as thumbnail_photo_content,
        cast(ThumbnailPhotoFileName as string)      as thumbnail_photo_file_name,
        cast(LargePhoto as string)                  as large_photo_content,
        cast(LargePhotoFileName as string)          as large_photo_file_name,

        -- Auditoria (armazenado como string no raw)
        cast(ModifiedDate as timestamp)             as modified_at
    from source
)

select * from renamed;