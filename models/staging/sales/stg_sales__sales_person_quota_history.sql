with source as (
    select * from {{ source('raw_sales', 'sales_salespersonquotahistory') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)           as sales_person_id,
        cast(rowguid as string)                 as row_guid,

        -- Período e valor da meta
        cast(QuotaDate as date)                 as quota_date,
        cast(SalesQuota as decimal(18, 4))      as sales_quota_amount,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;