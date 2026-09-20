with source as (
    select * from {{ source('raw_humanresources', 'humanresources_employeepayhistory') }}
),

renamed as (
    select
        -- Chaves
        cast(BusinessEntityID as int)       as business_entity_id,

        -- Dados de remuneração
        cast(RateChangeDate as date)        as rate_change_date,
        cast(Rate as decimal(18, 4))        as pay_rate,
        cast(PayFrequency as int)           as pay_frequency_code, -- 1 = Mensal, 2 = Quinzenal

        -- Auditoria
        cast(ModifiedDate as date)          as modified_date
    from source
)

select * from renamed;