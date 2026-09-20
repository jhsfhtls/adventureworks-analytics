with source as (
    select * from {{ source('raw_humanresources', 'humanresources_department') }}
),

renamed as (
    select
        cast(DepartmentID as int)               as department_id,
        cast(Name as string)                    as department_name,
        cast(GroupName as string)               as group_name,
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;