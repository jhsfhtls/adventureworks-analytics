with reps as (
    select * from {{ ref('int_sales_reps_enriched') }}
),

final as (
    select
        sales_person_id,
        sales_person_name,
        job_title,
        hire_date,
        is_current,
        territory_name,
        territory_group,
        sales_quota_amount,
        bonus_amount,
        commission_percentage
    from reps
)

select * from final;