with date_spine as (
    -- Gera série diária contínua de 2010 a 2026 compatível com Databricks SQL
    select explode(sequence(to_date('2010-01-01'), to_date('2026-12-31'), interval 1 day)) as date_day
),

transformed as (
    select
        cast(date_format(date_day, 'yyyyMMdd') as int) as date_key,
        date_day                                        as calendar_date,
        year(date_day)                                  as calendar_year,
        quarter(date_day)                               as calendar_quarter,
        month(date_day)                                 as calendar_month,
        date_format(date_day, 'MMMM')                   as month_name,
        date_format(date_day, 'MMM-yy')                 as month_year_code,
        day(date_day)                                   as day_of_month,
        dayofweek(date_day)                             as day_of_week,
        date_format(date_day, 'EEEE')                   as day_name,
        case 
            when dayofweek(date_day) in (1, 7) then true 
            else false 
        end                                             as is_weekend
    from date_spine
)

select * from transformed;