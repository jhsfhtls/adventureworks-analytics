with employees as (
    select * from {{ ref('stg_humanresources__employee') }}
),

persons as (
    select * from {{ ref('stg_person__person') }}
),

departments as (
    select * from {{ ref('stg_humanresources__department') }}
),

shifts as (
    select * from {{ ref('stg_humanresources__shift') }}
),

current_dept_history as (
    -- Filtra o departamento ativo atual
    select 
        business_entity_id,
        department_id,
        shift_id,
        start_date as department_start_date,
        row_number() over (partition by business_entity_id order by start_date desc) as rn
    from {{ ref('stg_humanresources__employee_department_history') }}
    where is_current_department = true or end_date is null
),

latest_pay as (
    -- Seleciona a taxa salarial vigente mais recente
    select
        business_entity_id,
        rate_change_date,
        pay_rate,
        pay_frequency_code,
        row_number() over (partition by business_entity_id order by rate_change_date desc) as rn
    from {{ ref('stg_humanresources__employee_pay_history') }}
),

joined as (
    select
        -- Chaves
        e.business_entity_id,
        cdh.department_id,
        cdh.shift_id,

        -- Dados pessoais
        concat_ws(' ', p.first_name, p.middle_name, p.last_name) as employee_name,
        e.login_id,
        e.job_title,
        e.gender_code,
        e.marital_status_code,

        -- Departamento e turno atuais
        coalesce(d.department_name, 'Não Atribuído') as department_name,
        coalesce(d.group_name, 'Não Atribuído')      as department_group_name,
        coalesce(s.shift_name, 'Padrão')             as shift_name,
        cdh.department_start_date,

        -- Condições contratuais e remuneração vigente
        e.hire_date,
        datediff(current_date(), e.hire_date) / 365.25 as tenure_years,
        e.is_salaried,
        e.is_current,
        lp.pay_rate                                  as current_pay_rate,
        lp.pay_frequency_code                        as current_pay_frequency_code,
        lp.rate_change_date                          as last_pay_change_date,

        -- Horas e licenças
        e.vacation_hours,
        e.sick_leave_hours,

        -- Auditoria
        e.modified_at
    from employees e
    inner join persons p
        on e.business_entity_id = p.business_entity_id
    left join current_dept_history cdh
        on e.business_entity_id = cdh.business_entity_id and cdh.rn = 1
    left join departments d
        on cdh.department_id = d.department_id
    left join shifts s
        on cdh.shift_id = s.shift_id
    left join latest_pay lp
        on e.business_entity_id = lp.business_entity_id and lp.rn = 1
)

select * from joined