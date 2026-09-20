with source as (
    select * from {{ source('raw_humanresources', 'humanresources_employeedepartmenthistory') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)       as business_entity_id,
        cast(DepartmentID as int)           as department_id,
        cast(ShiftID as int)                as shift_id,

        -- Período de vigência
        cast(StartDate as date)             as start_date,
        cast(EndDate as date)               as end_date,
        case 
            when EndDate is null then true 
            else false 
        end                                 as is_current_department,

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;