with vendors as (
    select * from {{ ref('int_vendors_enriched') }}
),

final as (
    select
        vendor_business_entity_id as vendor_id,
        vendor_account_number,
        vendor_name,
        credit_rating,
        case credit_rating
            when 1 then 'Excelente'
            when 2 then 'Muito Bom'
            when 3 then 'Regular'
            when 4 then 'Atenção'
            when 5 then 'Risco Alto'
            else 'Não Avaliado'
        end as credit_rating_description,
        is_preferred_vendor,
        is_active,
        city_name,
        state_province_name,
        country_region_name
    from vendors
)

select * from final;