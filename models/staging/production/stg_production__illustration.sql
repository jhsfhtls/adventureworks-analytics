with source as (
    select * from {{ source('raw_production', 'production_illustration') }}
),

renamed as (
    select
        -- Chaves
        cast(IllustrationID as int)         as illustration_id,

        -- Conteúdo gráfico / esquemático
        cast(Diagram as string)             as diagram_xml,

        -- Auditoria (armazenado como string no raw)
        cast(ModifiedDate as timestamp)     as modified_at
    from source
)

select * from renamed;