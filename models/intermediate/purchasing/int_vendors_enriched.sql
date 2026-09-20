with vendors as (
    select * from {{ ref('stg_purchasing__vendor') }}
),

entity_addresses as (
    select 
        business_entity_id,
        address_id,
        row_number() over (partition by business_entity_id order by address_type_id) as rn
    from {{ ref('stg_person__business_entity_address') }}
),

locations as (
    select * from {{ ref('int_locations_joined') }}
),

joined as (
    select
        -- Chaves
        v.vendor_business_entity_id,
        ea.address_id,

        -- Dados do fornecedor
        v.vendor_account_number,
        v.vendor_name,
        v.credit_rating,
        v.is_preferred_vendor,
        v.is_active,

        -- Localização física do fornecedor
        l.city_name,
        l.state_province_code,
        l.state_province_name,
        l.country_region_code,
        l.country_region_name,

        -- Auditoria
        v.modified_date
    from vendors v
    left join entity_addresses ea
        on v.vendor_business_entity_id = ea.business_entity_id and ea.rn = 1
    left join locations l
        on ea.address_id = l.address_id
)

select * from joined