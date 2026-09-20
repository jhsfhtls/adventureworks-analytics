with source as (
    select * from {{ source('raw_production', 'production_scrapreason') }}
),

renamed as (
    select
        -- Chaves
        cast(ScrapReasonID as int)          as scrap_reason_id,

        -- Atributos
        cast(Name as string)                as scrap_reason_name, -- Ex: 'Brake assembly not to spec', 'Color incorrect'

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;