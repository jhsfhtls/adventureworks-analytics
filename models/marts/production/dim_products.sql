with products as (
    select * from {{ ref('int_products_enriched') }}
),

final as (
    select
        -- Chaves
        product_id,
        product_number,

        -- Hierarquia de categorias
        category_name,
        subcategory_name,
        product_model_name,
        product_name,

        -- Classificações e atributos
        color_name,
        product_line_code,
        class_code,
        style_code,

        -- Flags operacionais
        is_manufactured_in_house,
        is_finished_goods,
        is_currently_sold,

        -- Parâmetros de estoque
        safety_stock_level,
        reorder_point_level,
        days_to_manufacture,

        -- Custos e preços de tabela
        standard_cost,
        list_price,
        standard_margin_amount,
        standard_margin_percentage,

        -- Dimensões físicas
        size,
        weight,

        -- Ciclo de vida
        sell_start_date,
        sell_end_date,
        discontinued_date
    from products
)

select * from final;