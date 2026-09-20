with source as (
    select * from {{ source('raw_production', 'production_culture') }}
),

renamed as (
    select
        -- Chaves
        cast(CultureID as string)           as culture_id, -- Ex: 'en', 'es', 'fr'

        -- Atributos
        cast(Name as string)                as culture_name,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;