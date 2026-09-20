with source as (
    select * from {{ source('raw_sales', 'sales_salesperson') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)           as sales_person_id,
        cast(TerritoryID as int)                as territory_id,
        cast(rowguid as string)                 as row_guid,

        -- Metas, comissões e bônus
        cast(SalesQuota as decimal(18, 4))      as sales_quota_amount,
        cast(Bonus as decimal(18, 4))           as bonus_amount,
        cast(CommissionPct as decimal(5, 4))    as commission_percentage,

        -- Desempenho acumulado
        cast(SalesYTD as decimal(18, 4))        as sales_ytd_amount,
        cast(SalesLastYear as decimal(18, 4))   as sales_last_year_amount,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;