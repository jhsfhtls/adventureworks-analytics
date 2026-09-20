with source as (
    select * from {{ source('raw_production', 'production_location') }}
),

renamed as (
    select
        -- Chaves
        cast(LocationID as int)                 as location_id,

        -- Dados da área/posto de fabricação
        cast(Name as string)                    as location_name, -- Ex: 'Subassembly', 'Paint', 'Frame Forming'
        cast(CostRate as decimal(18, 4))        as cost_rate_per_hour,
        cast(Availability as decimal(5, 2))     as availability_capacity_hours,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;