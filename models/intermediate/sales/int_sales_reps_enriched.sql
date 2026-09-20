with sales_persons as (
    select * from {{ ref('stg_sales__sales_person') }}
),

employees as (
    select * from {{ ref('stg_humanresources__employee') }}
),

persons as (
    select * from {{ ref('stg_person__person') }}
),

territories as (
    select * from {{ ref('stg_sales__sales_territory') }}
),

joined as (
    select
        -- Chaves
        sp.sales_person_id,
        sp.territory_id,

        -- Dados da pessoa / colaborador
        concat_ws(' ', p.first_name, p.middle_name, p.last_name) as sales_person_name,
        e.job_title,
        e.hire_date,
        e.is_current,

        -- Metas, comissões e bônus
        sp.sales_quota_amount,
        sp.bonus_amount,
        sp.commission_percentage,
        sp.sales_ytd_amount,
        sp.sales_last_year_amount,

        -- Território vinculado
        coalesce(t.territory_name, 'Não Atribuído') as territory_name,
        coalesce(t.country_region_code, 'N/A')     as country_region_code,
        coalesce(t.territory_group, 'N/A')         as territory_group,

        -- Auditoria
        sp.modified_date
    from sales_persons sp
    inner join employees e
        on sp.sales_person_id = e.business_entity_id
    inner join persons p
        on sp.sales_person_id = p.business_entity_id
    left join territories t
        on sp.territory_id = t.territory_id
)

select * from joined