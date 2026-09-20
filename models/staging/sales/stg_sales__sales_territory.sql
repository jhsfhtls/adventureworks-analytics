with source as (
    select * from {{ source('raw_sales', 'sales_salesterritory') }}
),

renamed as (
    select
        -- Chaves
        cast(TerritoryID as int)                as territory_id,
        cast(rowguid as string)                 as row_guid,

        -- Dados geográficos e agrupamento
        cast(Name as string)                    as territory_name, -- Ex: 'Northwest', 'United Kingdom', 'France'
        cast(CountryRegionCode as string)       as country_region_code,
        cast(`Group` as string)                 as territory_group, -- 'North America', 'Europe', 'Pacific'

        -- Métricas financeiras e custos acumulados
        cast(SalesYTD as decimal(18, 4))        as sales_ytd_amount,
        cast(SalesLastYear as decimal(18, 4))   as sales_last_year_amount,
        cast(CostYTD as decimal(18, 4))         as cost_ytd_amount,
        cast(CostLastYear as decimal(18, 4))    as cost_last_year_amount,

        -- Auditoria
        cast(ModifiedDate as date)              as modified_date
    from source
)

select * from renamed;