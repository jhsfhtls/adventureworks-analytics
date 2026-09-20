with source as (
    select * from {{ source('raw_production', 'production_unitmeasure') }}
),

renamed as (
    select
        -- Chaves
        cast(UnitMeasureCode as string)     as unit_measure_code, -- Ex: 'KG', 'M', 'EA', 'L'

        -- Atributos
        cast(Name as string)                as unit_measure_name,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;