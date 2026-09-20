"""
Queries de Detecção de Anomalias Operacionais — AdventureWorks Marts
Executam diretamente sobre o schema adventure_works.marts.
"""

# -----------------------------------------------------------------------------
# 1. Detecção de Ruptura de Estoque (Abaixo do Estoque de Segurança)
# -----------------------------------------------------------------------------
QUERY_CRITICAL_INVENTORY = """
SELECT 
    p.product_id,
    p.product_number AS sku,
    p.product_name,
    p.category_name,
    inv.shelf_code,
    inv.bin_number,
    inv.stock_quantity AS saldo_atual,
    inv.safety_stock_level AS estoque_seguranca,
    inv.reorder_point_level AS ponto_reposicao,
    (inv.safety_stock_level - inv.stock_quantity) AS deficit_unidades,
    inv.total_stock_cost_value AS valor_imobilizado_atual
FROM inventory_snapshots inv
INNER JOIN products p ON inv.product_id = p.product_id
WHERE inv.is_below_reorder_point = TRUE
   OR inv.stock_health_status = 'Crítico (Abaixo do Estoque de Segurança)'
ORDER BY deficit_unidades DESC, inv.stock_quantity ASC
LIMIT 15;
"""

# -----------------------------------------------------------------------------
# 2. Detecção de Fornecedores com Rejeição de Qualidade Acima de 3%
# -----------------------------------------------------------------------------
QUERY_SUPPLIER_QUALITY = """
SELECT 
    v.vendor_id,
    v.vendor_name,
    v.credit_rating_description,
    SUM(p.order_quantity) AS total_encomendado,
    SUM(p.received_quantity) AS total_recebido,
    SUM(p.rejected_quantity) AS total_rejeitado,
    ROUND(CAST(SUM(p.rejected_quantity) AS DOUBLE) / NULLIF(SUM(p.order_quantity), 0) * 100, 2) AS taxa_rejeicao_pct,
    ROUND(SUM(p.rejected_quantity * p.unit_price), 2) AS custo_prejuizo_rejeicao
FROM purchases p
INNER JOIN vendors v ON p.vendor_id = v.vendor_id
GROUP BY v.vendor_id, v.vendor_name, v.credit_rating_description
HAVING taxa_rejeicao_pct > 3.0
   AND total_rejeitado > 0
ORDER BY taxa_rejeicao_pct DESC, custo_prejuizo_rejeicao DESC
LIMIT 10;
"""
