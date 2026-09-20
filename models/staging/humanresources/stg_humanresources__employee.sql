with source as (
    select * from {{ source('raw_humanresources', 'humanresources_employee') }}
),

renamed as (
    select
        -- Chaves e identificadores
        cast(BusinessEntityID as int)           as business_entity_id,
        cast(NationalIDNumber as int)           as national_id_number,
        cast(LoginID as string)                 as login_id,
        cast(rowguid as string)                 as row_guid,

        -- Hierarquia e cargo
        cast(OrganizationNode as string)        as organization_node,
        cast(OrganizationLevel as int)          as organization_level,
        cast(JobTitle as string)                as job_title,

        -- Dados demográficos e contratuais
        cast(BirthDate as date)                 as birth_date,
        cast(MaritalStatus as string)           as marital_status_code, -- 'M' / 'S'
        cast(Gender as string)                  as gender_code,        -- 'M' / 'F'
        cast(HireDate as date)                  as hire_date,

        -- Flags e saldos de horas
        cast(SalariedFlag as boolean)           as is_salaried,
        cast(CurrentFlag as boolean)            as is_current,
        cast(VacationHours as int)              as vacation_hours,
        cast(SickLeaveHours as int)             as sick_leave_hours,

        -- Auditoria
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;