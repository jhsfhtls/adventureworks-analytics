with current_assignment as (
    select * from {{ ref('int_employees_current_assignment') }}
),

final as (
    select
        business_entity_id as employee_id,
        employee_name,
        login_id,
        job_title,
        gender_code,
        marital_status_code,
        department_name,
        department_group_name,
        shift_name,
        department_start_date,
        hire_date,
        round(tenure_years, 2)                              as tenure_years,
        is_salaried,
        is_current,
        current_pay_rate,
        current_pay_frequency_code,
        vacation_hours,
        sick_leave_hours
    from current_assignment
)

select * from final;