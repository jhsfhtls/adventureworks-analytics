with stock_status as (
    select * from {{ ref('int_inventory_stock_status') }}
),

final as (
    select
        -- Chaves compostas
        product_id,
        location_id,

        -- Localização no armazém
        shelf_code,
        bin_number,

        -- Indicadores de saúde do estoque
        stock_health_status,
        is_below_reorder_point,

        -- Métricas físicas e limites
        stock_quantity,
        safety_stock_level,
        reorder_point_level,

        -- Valores financeiros imobilizados
        unit_standard_cost,
        total_stock_cost_value                              -- Capital Total em Estoque
    from stock_status
)

select * from final;