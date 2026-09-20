with inventory as (
    select * from {{ ref('stg_production__product_inventory') }}
),

products as (
    select * from {{ ref('int_products_enriched') }}
),

locations as (
    select * from {{ ref('stg_production__location') }}
),

joined as (
    select
        -- Chaves
        inv.product_id,
        inv.location_id,

        -- Dados do produto e armazém
        p.product_number,
        p.product_name,
        p.category_name,
        p.subcategory_name,
        loc.location_name,
        inv.shelf_code,
        inv.bin_number,

        -- Quantidades físicas
        inv.stock_quantity,
        p.safety_stock_level,
        p.reorder_point_level,

        -- Valorização do estoque
        p.standard_cost                                 as unit_standard_cost,
        cast(inv.stock_quantity * p.standard_cost as decimal(18, 4)) as total_stock_cost_value,

        -- Indicadores e alertas de ruptura
        case 
            when inv.stock_quantity <= p.safety_stock_level then 'Crítico (Abaixo do Estoque de Segurança)'
            when inv.stock_quantity <= p.reorder_point_level then 'Alerta (Ponto de Reposição)'
            else 'Regular'
        end as stock_health_status,

        case 
            when inv.stock_quantity <= p.reorder_point_level then true 
            else false 
        end as is_below_reorder_point,

        -- Auditoria
        inv.modified_date
    from inventory inv
    inner join products p
        on inv.product_id = p.product_id
    inner join locations loc
        on inv.location_id = loc.location_id
)

select * from joined