"""
Cliente de Conexão com o Databricks SQL Warehouse
Lê variáveis de ambiente da raiz via find_dotenv().
"""

import os

import pandas as pd
from databricks import sql
from dotenv import find_dotenv, load_dotenv
from guardrails import validate_sql

# Carrega o .env da raiz do projeto
load_dotenv(find_dotenv())

# Lê DATABRICKS_HOST (removendo https:// se houver)
raw_host = os.getenv("DATABRICKS_HOST") or os.getenv("DATABRICKS_SERVER_HOSTNAME", "")
SERVER_HOSTNAME = raw_host.replace("https://", "").replace("http://", "").strip("/")

HTTP_PATH = os.getenv("DATABRICKS_HTTP_PATH")
ACCESS_TOKEN = os.getenv("DATABRICKS_TOKEN")
CATALOG = os.getenv("DATABRICKS_CATALOG", "adventure_works")
SCHEMA = os.getenv("DATABRICKS_SCHEMA", "marts")


def execute_query(raw_sql: str) -> pd.DataFrame:
    """
    Valida o SQL com guardrails e executa no Databricks Unity Catalog.
    Retorna o resultado como um DataFrame do Pandas.
    """
    # 1. Aplica a barreira de segurança (apenas SELECT e exclusivo da marts)
    safe_sql = validate_sql(raw_sql)

    # 2. Conecta ao Databricks fixando o catálogo e schema padrão em 'marts'
    with sql.connect(
        server_hostname=SERVER_HOSTNAME,
        http_path=HTTP_PATH,
        access_token=ACCESS_TOKEN,
        catalog=CATALOG,
        schema=SCHEMA,
    ) as connection:
        with connection.cursor() as cursor:
            cursor.execute(safe_sql)
            result = cursor.fetchall()
            columns = [desc[0] for desc in cursor.description]
            return pd.DataFrame(result, columns=columns)


# Teste rápido de conexão
if __name__ == "__main__":
    print(f"Testando conexão com Databricks ({CATALOG}.{SCHEMA})...")
    print(f"Host: {SERVER_HOSTNAME}")
    try:
        df_teste = execute_query(
            "SELECT product_id, product_name, category_name, list_price FROM products LIMIT 5"
        )
        print("\n✅ Conexão bem-sucedida! Amostra da camada Marts:")
        print(df_teste)
    except Exception as e:
        print(f"\n❌ Erro ao conectar: {e}")
