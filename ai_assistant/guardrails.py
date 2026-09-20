"""
Módulo de Segurança e Governança (Guardrails)
Garante que o Agente opere com privilégios mínimos:
1. Apenas comandos de leitura (SELECT).
2. Acesso exclusivo ao schema 'marts'.
3. Bloqueio absoluto de 'staging', 'raw', 'intermediate' e comandos DDL/DML.
"""

import re


class SecurityViolationError(Exception):
    """Exceção disparada quando uma query viola as políticas de governança."""

    pass


# Lista de comandos estritamente proibidos
FORBIDDEN_COMMANDS = [
    r"\bDROP\b",
    r"\bDELETE\b",
    r"\bUPDATE\b",
    r"\bINSERT\b",
    r"\bALTER\b",
    r"\bTRUNCATE\b",
    r"\bCREATE\b",
    r"\bGRANT\b",
    r"\bREVOKE\b",
    r"\bMERGE\b",
    r"\bEXEC\b",
    r"\bEXECUTE\b",
]

# Schemas proibidos (fora da camada marts)
FORBIDDEN_SCHEMAS = [
    r"\bstaging\b",
    r"\braw\b",
    r"\bintermediate\b",
    r"\binformation_schema\b",
    r"\bdefault\b",
]


def validate_sql(query: str) -> str:
    """Valida a query SQL contra as regras de governança e aplica proteções.

    Retorna a query limpa ou dispara SecurityViolationError.
    """
    cleaned_query = query.strip()

    # Remove bloco de markdown ```sql ... ``` se houver
    if cleaned_query.startswith("```"):
        lines = cleaned_query.splitlines()
        if lines[0].startswith("```"):
            lines = lines[1:]
        if lines and lines[-1].startswith("```"):
            lines = lines[:-1]
        cleaned_query = "\n".join(lines).strip()

    # 1. Verifica se começa com SELECT ou WITH
    if not re.match(r"^(SELECT|WITH)\b", cleaned_query, re.IGNORECASE):
        raise SecurityViolationError(
            "Violação de Segurança: Apenas consultas de leitura (SELECT) são permitidas."
        )

    # 2. Bloqueia comandos DDL e DML
    for pattern in FORBIDDEN_COMMANDS:
        if re.search(pattern, cleaned_query, re.IGNORECASE):
            cmd = pattern.replace(r"\b", "")
            raise SecurityViolationError(
                f"Violação de Segurança: O comando destrutivo '{cmd}' é proibido."
            )

    # 3. Bloqueia acesso a outros schemas que não sejam a Marts
    for pattern in FORBIDDEN_SCHEMAS:
        if re.search(pattern, cleaned_query, re.IGNORECASE):
            schema_name = pattern.replace(r"\b", "")
            raise SecurityViolationError(
                f"Violação de Segurança: Acesso negado ao schema '{schema_name}'. "
                "O agente só possui autorização para consultar a camada 'marts'."
            )

    # 4. Injeta LIMIT automático de segurança se não houver
    if not re.search(r"\bLIMIT\s+\d+\b", cleaned_query, re.IGNORECASE):
        cleaned_query = f"{cleaned_query.rstrip(';')} LIMIT 200"

    return cleaned_query
