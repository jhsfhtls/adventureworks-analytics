with source as (
    select * from {{ source('raw_sales', 'sales_currencyrate') }}
),

renamed as (
    select
        -- Chaves e moedas
        cast(CurrencyRateID as int)             as currency_rate_id,
        cast(CurrencyRateDate as date)          as currency_rate_date,
        cast(FromCurrencyCode as string)        as from_currency_code,
        cast(ToCurrencyCode as string)          as to_currency_code,

        -- Taxas de câmbio
        cast(AverageRate as decimal(18, 4))     as average_exchange_rate,
        cast(EndOfDayRate as decimal(18, 4))    as end_of_day_exchange_rate,

        -- Auditoria
        cast(ModifiedDate as timestamp)         as modified_at
    from source
)

select * from renamed;