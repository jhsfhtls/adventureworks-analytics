with source as (
    select * from {{ source('raw_humanresources', 'humanresources_shift') }}
),

renamed as (
    select
        -- Chaves
        cast(ShiftID as int)                as shift_id,

        -- Detalhes do turno
        cast(Name as string)                as shift_name,
        cast(StartTime as string)           as start_time,
        cast(EndTime as string)             as end_time,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;