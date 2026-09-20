with source as (
    select * from {{ source('raw_dbo', 'dbo_awbuildversion') }}
),

renamed as (
    select
        cast(SystemInformationID as int)        as system_information_id,
        cast(Database_Version as string)        as database_version,
        cast(VersionDate as timestamp)          as version_date,
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;