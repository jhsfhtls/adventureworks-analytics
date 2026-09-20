with products as (
    select * from {{ ref('stg_production__product') }}
),

subcategories as (
    select * from {{ ref('stg_production__product_subcategory') }}
),

categories as (
    select * from {{ ref('stg_production__product_category') }}
),

models as (
    select * from {{ ref('stg_production__product_model') }}
),

joined as (
    select
        -- Chaves
        p.product_id,
        p.product_number,
        p.product_subcategory_id,
        s.product_category_id,
        p.product_model_id,

        -- Nomes e hierarquia de categorias
        p.product_name,
        coalesce(s.subcategory_name, 'Outros')          as subcategory_name,
        coalesce(c.category_name, 'Outros')             as category_name,
        coalesce(m.product_model_name, 'Sem Modelo')    as product_model_name,

        -- Características físicas e classificação
        p.color_name,
        p.product_line_code,
        p.class_code,
        p.style_code,
        p.size,
        p.size_unit_measure_code,
        p.weight,
        p.weight_unit_measure_code,

        -- Flags operacionais
        p.is_manufactured_in_house,
        p.is_finished_goods,
        p.is_currently_sold,

        -- Parâmetros fabris e de estoque
        p.safety_stock_level,
        p.reorder_point_level,
        p.days_to_manufacture,

        -- Custos, preços e margem padrão
        p.standard_cost,
        p.list_price,
        cast(p.list_price - p.standard_cost as decimal(18, 4)) as standard_margin_amount,
        case 
            when p.list_price > 0 
            then cast((p.list_price - p.standard_cost) / p.list_price as decimal(10, 4))
            else 0.0 
        end as standard_margin_percentage,

        -- Ciclo de vida do produto
        p.sell_start_date,
        p.sell_end_date,
        p.discontinued_date,

        -- Auditoria
        p.modified_at
    from products p
    left join subcategories s
        on p.product_subcategory_id = s.product_subcategory_id
    left join categories c
        on s.product_category_id = c.product_category_id
    left join models m
        on p.product_model_id = m.product_model_id
)

select * from joined