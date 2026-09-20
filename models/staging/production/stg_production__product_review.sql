with source as (
    select * from {{ source('raw_production', 'production_productreview') }}
),

renamed as (
    select
        -- Chaves (armazenados como string no raw)
        cast(ProductReviewID as int)        as product_review_id,
        cast(ProductID as int)              as product_id,

        -- Dados da avaliação
        cast(ReviewerName as string)        as reviewer_name,
        cast(ReviewDate as timestamp)       as reviewed_at,
        cast(EmailAddress as string)        as reviewer_email_address,
        cast(Rating as int)                 as rating_score, -- Escala de 1 a 5
        cast(Comments as string)            as review_comment,

        -- Auditoria (armazenado como string no raw)
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;