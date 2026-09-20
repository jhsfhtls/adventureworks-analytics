with source as (
    select * from {{ source('raw_dbo', 'dbo_databaselog') }}
),

renamed as (
    select
        cast(DatabaseLogID as int)              as database_log_id,
        cast(PostTime as timestamp)             as posted_at,
        cast(DatabaseUser as string)            as database_user,
        cast(Event as string)                   as event_name,
        cast(Schema as string)                  as schema_name,
        cast(Object as string)                  as object_name,
        cast(TSQL as string)                    as tsql_query,
        cast(XmlEvent as string)                as xml_event
    from source
)

select * from renamed;