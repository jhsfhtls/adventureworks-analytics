with source as (
    select * from {{ source('raw_dbo', 'dbo_errorlog') }}
),

renamed as (
    select
        cast(ErrorLogID as int)                 as error_log_id,
        cast(ErrorTime as timestamp)            as error_at,
        cast(UserName as string)                as user_name,
        cast(ErrorNumber as int)                as error_number,
        cast(ErrorSeverity as int)              as error_severity,
        cast(ErrorState as int)                 as error_state,
        cast(ErrorProcedure as string)          as error_procedure,
        cast(ErrorLine as int)                  as error_line,
        cast(ErrorMessage as string)            as error_message
    from source
)

select * from renamed;