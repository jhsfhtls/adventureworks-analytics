"""
Módulo de Observabilidade Contínua — AdventureWorks Analytics
Monitora volumetria, contagem de linhas e integridade das tabelas da Marts.
"""

import os
from datetime import datetime

import pandas as pd
from databricks import sql
from dotenv import find_dotenv, load_dotenv

load_dotenv(find_dotenv())

# Configurações de Conexão com Databricks
raw_host = os.getenv("DATABRICKS_HOST") or os.getenv("DATABRICKS_SERVER_HOSTNAME", "")
SERVER_HOSTNAME = raw_host.replace("https://", "").replace("http://", "").strip("/")
HTTP_PATH = os.getenv("DATABRICKS_HTTP_PATH")
ACCESS_TOKEN = os.getenv("DATABRICKS_TOKEN")
CATALOG = os.getenv("DATABRICKS_CATALOG", "adventure_works")
SCHEMA = os.getenv("DATABRICKS_SCHEMA", "marts")

# Tabelas da Camada Gold que serão monitoradas
MARTS_TABLES = [
    "sales",
    "work_orders",
    "purchases",
    "inventory_snapshots",
    "products",
    "customers",
    "dates",
    "sales_reps",
    "vendors",
    "employees",
]


def audit_marts_health():
    """Coleta métricas de volumetria e status das tabelas físicas no Databricks."""
    print("=" * 65)
    print("📈 Auditoria de Observabilidade de Dados (adventure_works.marts)")
    print(f"Timestamp: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 65)

    metrics = []

    with sql.connect(
        server_hostname=SERVER_HOSTNAME,
        http_path=HTTP_PATH,
        access_token=ACCESS_TOKEN,
        catalog=CATALOG,
        schema=SCHEMA,
    ) as connection:
        with connection.cursor() as cursor:
            for table in MARTS_TABLES:
                query = f"SELECT COUNT(*) AS total_rows FROM {table}"
                try:
                    cursor.execute(query)
                    total_rows = cursor.fetchone()[0]
                    status = "✅ Saudável" if total_rows > 0 else "⚠️ Vazio"
                    metrics.append(
                        {
                            "Tabela": table,
                            "Total de Linhas": total_rows,
                            "Status": status,
                        }
                    )
                except Exception as e:
                    metrics.append(
                        {
                            "Tabela": table,
                            "Total de Linhas": 0,
                            "Status": f"❌ Erro: {e}",
                        }
                    )

    df_metrics = pd.DataFrame(metrics)
    print("\nRelatório de Volumetria da Camada Gold:")
    print(df_metrics.to_markdown(index=False))

    # Identifica anomalias críticas (tabelas zeradas)
    empty_tables = df_metrics[df_metrics["Total de Linhas"] == 0]
    if not empty_tables.empty:
        print(
            f"\n🚨 ALERTA DE OBSERVABILIDADE: {len(empty_tables)} tabela(s) sem dados detectada(s)!"
        )
    else:
        print("\n✅ Todas as tabelas da camada Marts possuem dados íntegros!")

    return df_metrics


if __name__ == "__main__":
    audit_marts_health()
