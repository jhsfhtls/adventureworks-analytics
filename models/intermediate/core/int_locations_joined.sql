with addresses as (
    select * from {{ ref('stg_person__address') }}
),

state_provinces as (
    select * from {{ ref('stg_person__state_province') }}
),

countries as (
    select * from {{ ref('stg_person__country_region') }}
),

joined as (
    select
        -- Chaves
        a.address_id,
        a.state_province_id,
        sp.territory_id,
        sp.country_region_code,

        -- Logradouro e código postal
        a.address_line_1,
        a.address_line_2,
        a.city_name,
        a.postal_code,

        -- Estado / Província
        sp.state_province_code,
        sp.state_province_name,
        sp.is_only_state_province,

        -- País / Região
        c.country_region_name,

        -- Auditoria
        a.modified_at
    from addresses a
    left join state_provinces sp
        on a.state_province_id = sp.state_province_id
    left join countries c
        on sp.country_region_code = c.country_region_code
)

select * from joined