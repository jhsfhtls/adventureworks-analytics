with customers as (
    select * from {{ ref('int_customers_unified') }}
),

locations as (
    select * from {{ ref('int_locations_joined') }}
),

customer_addresses as (
    select 
        c.customer_id,
        bea.address_id,
        row_number() over (partition by c.customer_id order by bea.address_type_id) as rn
    from customers c
    inner join {{ ref('stg_person__business_entity_address') }} bea
        on coalesce(c.person_id, c.store_id) = bea.business_entity_id
),

final as (
    select
        -- Chaves
        c.customer_id,
        c.customer_account_number,

        -- Perfil do cliente
        c.customer_type,
        c.customer_name,
        c.email_address,
        c.phone_number,

        -- Território e Região
        c.territory_name,
        c.territory_group,

        -- Localização geográfica
        coalesce(loc.city_name, 'Não Informado')            as city_name,
        coalesce(loc.state_province_code, 'N/A')            as state_province_code,
        coalesce(loc.state_province_name, 'Não Informado')  as state_province_name,
        coalesce(loc.country_region_name, 'Não Informado')  as country_region_name
    from customers c
    left join customer_addresses ca
        on c.customer_id = ca.customer_id and ca.rn = 1
    left join locations loc
        on ca.address_id = loc.address_id
)

select * from final;