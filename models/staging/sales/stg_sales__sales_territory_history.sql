with source as (
    select * from {{ source('raw_sales', 'sales_salesterritoryhistory') }}
),

renamed as (
    select
        -- Chaves compostas
        cast(BusinessEntityID as int)           as sales_person_id,
        cast(TerritoryID as int)                as territory_id,
        cast(rowguid as string)                 as row_guid,

        -- Período de atuação
        cast(StartDate as date)                 as start_date,
        cast(EndDate as date)                   as end_date,
        case 
            when EndDate is null then true 
            else false 
        end                                     as is_current_territory,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;