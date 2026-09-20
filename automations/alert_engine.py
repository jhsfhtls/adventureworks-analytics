# Databricks notebook source
# MAGIC %md
# MAGIC # 🔔 Rotina Diária de Alertas Proativos — AdventureWorks Marts

# COMMAND ----------

import json
import urllib.request

import pandas as pd

# -----------------------------------------------------------------------------
# 1. Configurações e Webhooks (Insira a URL real do Teams se tiver)
# -----------------------------------------------------------------------------
# Caso não tenha a URL, deixe vazio para rodar em modo Simulação (Console)
TEAMS_WEBHOOK_URL = ""


def send_teams_alert(
    title: str,
    subtitle: str,
    summary_text: str,
    facts: list,
    color: str = "d9534f",
) -> bool:
    """Envia ou simula o card de notificação formatado para o Teams."""
    payload = {
        "@type": "MessageCard",
        "@context": "http://schema.org/extensions",
        "themeColor": color,
        "summary": title,
        "sections": [
            {
                "activityTitle": f"🔔 **{title}**",
                "activitySubtitle": subtitle,
                "text": summary_text,
                "facts": facts,
                "markdown": True,
            }
        ],
        "potentialAction": [
            {
                "@type": "OpenUri",
                "name": "📊 Abrir Power BI Dashboard",
                "targets": [{"os": "default", "uri": "https://app.powerbi.com"}],
            }
        ],
    }

    if not TEAMS_WEBHOOK_URL:
        print(f"\n[SIMULAÇÃO TEAMS] -> {title}")
        print(f"Resumo: {summary_text}")
        for fact in facts:
            print(f"   • {fact['name']}: {fact['value']}")
        return True

    try:
        data = json.dumps(payload).encode("utf-8")
        req = urllib.request.Request(
            TEAMS_WEBHOOK_URL,
            data=data,
            headers={"Content-Type": "application/json"},
        )
        with urllib.request.urlopen(req) as response:
            return response.status == 200
    except Exception as e:
        print(f"❌ Erro ao enviar webhook para o Teams: {e}")
        return False


# -----------------------------------------------------------------------------
# 2. Função Nativa de Execução no Databricks
# -----------------------------------------------------------------------------
def get_databricks_data(query_sql: str) -> pd.DataFrame:
    """Executa a query diretamente no cluster usando a sessão nativa do Spark."""
    return spark.sql(query_sql).toPandas()


# -----------------------------------------------------------------------------
# 3. Queries Analíticas de Detecção
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
FROM adventure_works.marts.inventory_snapshots inv
INNER JOIN adventure_works.marts.products p ON inv.product_id = p.product_id
WHERE inv.is_below_reorder_point = TRUE
   OR inv.stock_health_status = 'Crítico (Abaixo do Estoque de Segurança)'
ORDER BY deficit_unidades DESC, inv.stock_quantity ASC
LIMIT 15
"""

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
FROM adventure_works.marts.purchases p
INNER JOIN adventure_works.marts.vendors v ON p.vendor_id = v.vendor_id
GROUP BY v.vendor_id, v.vendor_name, v.credit_rating_description
HAVING taxa_rejeicao_pct > 3.0
   AND total_rejeitado > 0
ORDER BY taxa_rejeicao_pct DESC, custo_prejuizo_rejeicao DESC
LIMIT 10
"""

# -----------------------------------------------------------------------------
# 4. Processamento dos Alertas
# -----------------------------------------------------------------------------


def process_inventory_alert():
    print("1. Verificando integridade física do estoque...")
    df = get_databricks_data(QUERY_CRITICAL_INVENTORY)

    if df.empty:
        print("-> Nenhum produto em situação crítica de estoque.")
        return

    total_skus = len(df)
    maior_deficit = df.iloc[0]

    facts = [
        {"name": "Total de SKUs em Risco", "value": str(total_skus)},
        {
            "name": "Maior Déficit (Peça)",
            "value": f"{maior_deficit['product_name']} ({maior_deficit['sku']})",
        },
        {
            "name": "Saldo Atual vs. Segurança",
            "value": (
                f"{maior_deficit['saldo_atual']} un (Segurança:"
                f" {maior_deficit['estoque_seguranca']} un)"
            ),
        },
        {
            "name": "Déficit Máximo",
            "value": f"-{maior_deficit['deficit_unidades']} unidades",
        },
        {
            "name": "Prateleira / Posição",
            "value": (
                f"Armazém {maior_deficit['shelf_code']} (Bin"
                f" {maior_deficit['bin_number']})"
            ),
        },
    ]

    summary = (
        f"Foram identificados **{total_skus} produtos** abaixo do estoque de"
        " segurança estipulado pela engenharia. Ação imediata de reposição"
        " recomendada."
    )

    send_teams_alert(
        title="ALERTA DE RUPTURA: Estoque Crítico Detectado",
        subtitle=(
            "Databricks Unity Catalog — adventure_works.marts.inventory_snapshots"
        ),
        summary_text=summary,
        facts=facts,
        color="d9534f",
    )


def process_supplier_quality_alert():
    print("\n2. Verificando qualidade e conformidade de compras...")
    df = get_databricks_data(QUERY_SUPPLIER_QUALITY)

    if df.empty:
        print("-> Todos os fornecedores estão dentro da taxa tolerada de 3%.")
        return

    total_fornecedores = len(df)
    pior_fornecedor = df.iloc[0]

    facts = [
        {
            "name": "Fornecedores em Alerta (> 3%)",
            "value": str(total_fornecedores),
        },
        {
            "name": "Fornecedor Mais Crítico",
            "value": (
                f"{pior_fornecedor['vendor_name']} (Rating:"
                f" {pior_fornecedor['credit_rating_description']})"
            ),
        },
        {
            "name": "Taxa de Rejeição Apurada",
            "value": f"**{pior_fornecedor['taxa_rejeicao_pct']}%** (Teto: 3,0%)",
        },
        {
            "name": "Peças Rejeitadas na Doca",
            "value": f"{int(pior_fornecedor['total_rejeitado'])} unidades",
        },
        {
            "name": "Prejuízo Acumulado em Refugo",
            "value": f"R$ {pior_fornecedor['custo_prejuizo_rejeicao']:,.2f}",
        },
    ]

    summary = (
        f"Detectados **{total_fornecedores} fornecedores** com taxa de refugo de"
        " insumos superior a 3%. Recomenda-se acionar o time de Suprimentos para"
        " renegociação de lote ou penalidades."
    )

    send_teams_alert(
        title="ALERTA DE QUALIDADE: Fornecedor com Refugo Excessivo",
        subtitle="Databricks Unity Catalog — adventure_works.marts.purchases",
        summary_text=summary,
        facts=facts,
        color="f0ad4e",
    )


# Execução do Job
print("=" * 65)
print("🔔 Disparando Job de Monitoramento Analítico...")
print("=" * 65)
process_inventory_alert()
process_supplier_quality_alert()
print("\n✅ Execução finalizada com sucesso!")
