with customers as (
    select * from {{ ref('stg_sales__customer') }}
),

persons as (
    select * from {{ ref('stg_person__person') }}
),

stores as (
    select * from {{ ref('stg_sales__store') }}
),

territories as (
    select * from {{ ref('stg_sales__sales_territory') }}
),

emails as (
    -- Deduplica para garantir no máximo 1 e-mail por pessoa
    select 
        business_entity_id,
        email_address,
        row_number() over (partition by business_entity_id order by email_address_id) as rn
    from {{ ref('stg_person__email_address') }}
),

phones as (
    -- Deduplica para garantir no máximo 1 telefone principal por pessoa
    select 
        business_entity_id,
        phone_number,
        row_number() over (partition by business_entity_id order by phone_number_type_id) as rn
    from {{ ref('stg_person__person_phone') }}
),

joined as (
    select
        -- Chaves
        c.customer_id,
        c.person_id,
        c.store_id,
        c.territory_id,
        c.customer_account_number,

        -- Classificação do cliente
        c.customer_type,

        -- Nome do cliente (Se B2B usa a Razão Social da Loja, se B2C usa o Nome Completo da Pessoa)
        case 
            when c.store_id is not null then s.store_name
            else concat_ws(' ', p.first_name, p.middle_name, p.last_name)
        end as customer_name,

        -- Contatos (prioritariamente da pessoa física ou contato B2C)
        e.email_address,
        ph.phone_number,

        -- Território comercial
        t.territory_name,
        t.country_region_code,
        t.territory_group,

        -- Auditoria
        c.modified_at
    from customers c
    left join persons p
        on c.person_id = p.business_entity_id
    left join stores s
        on c.store_id = s.store_business_entity_id
    left join territories t
        on c.territory_id = t.territory_id
    left join emails e
        on c.person_id = e.business_entity_id and e.rn = 1
    left join phones ph
        on c.person_id = ph.business_entity_id and ph.rn = 1
)

select * from joined