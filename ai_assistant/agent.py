"""
Agente Orquestrador Text-to-SQL — AdventureWorks Analytics
Conecta ao Databricks e trata erros de limite de cota da API (Rate Limit 429).
"""

import os
import re

import pandas as pd
from databricks_client import execute_query
from dotenv import find_dotenv, load_dotenv
from langchain_core.output_parsers import StrOutputParser
from langchain_core.prompts import PromptTemplate
from langchain_google_genai import ChatGoogleGenerativeAI
from prompts import SYSTEM_PROMPT_SQL, SYSTEM_PROMPT_SYNTHESIS

# Carrega variáveis de ambiente (.env da raiz)
load_dotenv(find_dotenv())

# Inicialização do Modelo LLM (Gemini 3.6 Flash)
model_name = os.getenv("GEMINI_MODEL", "gemini-3.6-flash")
llm = ChatGoogleGenerativeAI(
    model=model_name,
    temperature=0.1,
)
llm.__dict__["model"] = model_name


def extrair_sql(resposta_llm) -> str:
    """Extrai apenas a instrução SQL de dentro dos blocos de markdown."""
    if isinstance(resposta_llm, list):
        partes = []
        for p in resposta_llm:
            if isinstance(p, dict) and "text" in p:
                partes.append(p["text"])
            elif isinstance(p, str):
                partes.append(p)
            else:
                partes.append(str(p))
        texto = "\n".join(partes)
    else:
        texto = str(resposta_llm)

    match = re.search(r"```sql\s*(.*?)\s*```", texto, re.DOTALL | re.IGNORECASE)
    if match:
        return match.group(1).strip()
    return texto.strip().replace("```", "")


def responder_pergunta(pergunta_usuario: str) -> dict:
    """Fluxo completo com proteção contra limite de requisições (Rate Limit 429)."""

    # 1. Geração de SQL via LLM com proteção
    try:
        prompt_sql = PromptTemplate.from_template(
            "{system_prompt}\n\nPergunta do usuário: {pergunta}\n\nSQL:"
        )
        chain_sql = prompt_sql | llm | StrOutputParser()

        resposta_bruta = chain_sql.invoke(
            {"system_prompt": SYSTEM_PROMPT_SQL, "pergunta": pergunta_usuario}
        )

        sql_query = extrair_sql(resposta_bruta)

    except Exception as erro:
        msg_erro = str(erro)
        if "429" in msg_erro or "RESOURCE_EXHAUSTED" in msg_erro:
            return {
                "sucesso": False,
                "sql": None,
                "resposta": (
                    "⚠️ **Limite de requisições da API do Google atingido (Rate Limit 429)**.<br>"
                    "Aguarde cerca de 1 minuto para o Google renovar a cota e tente novamente."
                ),
                "dados": None,
            }
        return {
            "sucesso": False,
            "sql": None,
            "resposta": f"❌ Erro ao gerar SQL via IA: {erro}",
            "dados": None,
        }

    # 2. Execução segura no Databricks com Guardrails
    try:
        df_resultado = execute_query(sql_query)
    except Exception as erro:
        return {
            "sucesso": False,
            "sql": sql_query,
            "resposta": f"❌ Não foi possível executar a consulta com segurança no Databricks:\n{erro}",
            "dados": None,
        }

    # 3. Síntese dos Resultados com proteção
    try:
        if df_resultado.empty:
            dados_md = "Nenhum registro encontrado para o filtro aplicado."
        else:
            dados_md = df_resultado.to_markdown(index=False)

        prompt_sintese = PromptTemplate.from_template(SYSTEM_PROMPT_SYNTHESIS)
        chain_sintese = prompt_sintese | llm | StrOutputParser()

        resposta_final = chain_sintese.invoke(
            {
                "pergunta": pergunta_usuario,
                "sql_query": sql_query,
                "dados_tabela": dados_md,
            }
        )

    except Exception as erro:
        msg_erro = str(erro)
        if "429" in msg_erro or "RESOURCE_EXHAUSTED" in msg_erro:
            return {
                "sucesso": True,
                "sql": sql_query,
                "resposta": (
                    "⚠️ **A consulta rodou no Databricks com sucesso, mas a síntese da resposta atingiu o limite da API (429)**.<br>"
                    "Você pode conferir os dados brutos e o SQL nos botões abaixo."
                ),
                "dados": df_resultado,
            }
        resposta_final = (
            f"Dados retornados com sucesso, mas houve falha na síntese: {erro}"
        )

    return {
        "sucesso": True,
        "sql": sql_query,
        "resposta": resposta_final,
        "dados": df_resultado,
    }
