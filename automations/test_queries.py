"""
Script de Teste da Etapa 1 — Validação das Queries de Alerta no Databricks
"""

import os

import pandas as pd
from databricks import sql
from dotenv import find_dotenv, load_dotenv
from queries import QUERY_CRITICAL_INVENTORY, QUERY_SUPPLIER_QUALITY

# Carrega o .env da raiz
load_dotenv(find_dotenv())

raw_host = os.getenv("DATABRICKS_HOST") or os.getenv("DATABRICKS_SERVER_HOSTNAME", "")
SERVER_HOSTNAME = raw_host.replace("https://", "").replace("http://", "").strip("/")
HTTP_PATH = os.getenv("DATABRICKS_HTTP_PATH")
ACCESS_TOKEN = os.getenv("DATABRICKS_TOKEN")
CATALOG = os.getenv("DATABRICKS_CATALOG", "adventure_works")
SCHEMA = os.getenv("DATABRICKS_SCHEMA", "marts")


def run_test_query(query_sql: str, query_name: str) -> pd.DataFrame:
    """Executa a query no Databricks e retorna o DataFrame."""
    print(f"\n" + "=" * 60)
    print(f"🔍 Executando: {query_name}...")
    print("=" * 60)

    with sql.connect(
        server_hostname=SERVER_HOSTNAME,
        http_path=HTTP_PATH,
        access_token=ACCESS_TOKEN,
        catalog=CATALOG,
        schema=SCHEMA,
    ) as connection:
        with connection.cursor() as cursor:
            cursor.execute(query_sql)
            result = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]
            df = pd.DataFrame(result, columns=columns)
            return df


if __name__ == "__main__":
    print(f"Conectando ao Databricks ({CATALOG}.{SCHEMA})...")

    # 1. Teste de Estoque Crítico
    try:
        df_estoque = run_test_query(
            QUERY_CRITICAL_INVENTORY, "ALERTA 1 - ESTOQUE CRÍTICO"
        )
        print(f"-> Foram encontrados {len(df_estoque)} SKUs com alerta de ruptura!")
        if not df_estoque.empty:
            print(
                df_estoque[
                    [
                        "sku",
                        "product_name",
                        "saldo_atual",
                        "estoque_seguranca",
                        "deficit_unidades",
                    ]
                ].head(5)
            )
    except Exception as e:
        print(f"❌ Erro na query de estoque: {e}")

    # 2. Teste de Qualidade de Fornecedores
    try:
        df_qualidade = run_test_query(
            QUERY_SUPPLIER_QUALITY, "ALERTA 2 - FORNECEDORES > 3% REJEIÇÃO"
        )
        print(
            f"\n-> Foram encontrados {len(df_qualidade)} fornecedores acima do"
            " teto de 3% de refugo!"
        )
        if not df_qualidade.empty:
            print(
                df_qualidade[
                    [
                        "vendor_name",
                        "total_rejeitado",
                        "taxa_rejeicao_pct",
                        "custo_prejuizo_rejeicao",
                    ]
                ].head(5)
            )
    except Exception as e:
        print(f"❌ Erro na query de fornecedores: {e}")
