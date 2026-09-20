"""
AdventureWorks AI Assistant — Floating Widget (Canto Inferior Direito)
Interface moderna com chatbot flutuante sobreposto à plataforma executiva.
"""

import os

import pandas as pd
import streamlit as st
from agent import responder_pergunta

# -----------------------------------------------------------------------------
# 1. Configuração da Página
# -----------------------------------------------------------------------------
st.set_page_config(
    page_title="AdventureWorks Analytics Platform",
    page_icon="🚴",
    layout="wide",
    initial_sidebar_state="collapsed",
)

# -----------------------------------------------------------------------------
# 2. Estilização CSS para Criar o Widget Flutuante no Canto Inferior Direito
# -----------------------------------------------------------------------------
st.markdown(
    """
<style>
    /* Estilo do fundo da tela principal */
    .stApp {
        background-color: #0B0F19;
        color: #F8FAFC;
    }
    
    /* Botão flutuante no canto inferior direito */
    .floating-btn-container {
        position: fixed;
        bottom: 25px;
        right: 25px;
        z-index: 999999;
    }
    
    /* Container flutuante do Chat */
    .floating-chat-window {
        position: fixed;
        bottom: 85px;
        right: 25px;
        width: 440px;
        max-width: 90vw;
        height: 640px;
        max-height: 80vh;
        background-color: #0F172A;
        border: 1px solid #334155;
        border-radius: 16px;
        box-shadow: 0 20px 35px -5px rgba(0, 0, 0, 0.7);
        z-index: 999998;
        display: flex;
        flex-direction: column;
        overflow: hidden;
    }
    
    /* Cabeçalho do Chat */
    .chat-header {
        padding: 14px 18px;
        background-color: #1E293B;
        border-bottom: 1px solid #334155;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .chat-header-title {
        font-weight: 700;
        font-size: 15px;
        color: #F8FAFC;
        display: flex;
        align-items: center;
        gap: 8px;
    }
    .chat-status {
        font-size: 11px;
        color: #10B981;
        font-weight: 500;
    }

    /* Área das mensagens com scroll suave */
    .chat-body {
        padding: 16px;
        flex: 1;
        overflow-y: auto;
    }

    /* Mensagens individuais */
    .msg-user {
        background-color: #2563EB;
        color: #FFFFFF;
        padding: 10px 14px;
        border-radius: 14px 14px 2px 14px;
        margin-bottom: 10px;
        max-width: 85%;
        margin-left: auto;
        font-size: 13.5px;
        line-height: 1.4;
    }
    .msg-bot {
        background-color: #1E293B;
        color: #E2E8F0;
        padding: 12px 16px;
        border-radius: 14px 14px 14px 2px;
        margin-bottom: 10px;
        max-width: 90%;
        border: 1px solid #334155;
        font-size: 13px;
        line-height: 1.45;
    }

    /* Cards da Página Principal */
    .metric-card {
        background-color: #161F30;
        border: 1px solid #223049;
        border-radius: 12px;
        padding: 20px;
        margin-bottom: 15px;
    }
</style>
""",
    unsafe_allow_html=True,
)

# -----------------------------------------------------------------------------
# 3. Estado da Sessão (Aberto / Fechado e Mensagens)
# -----------------------------------------------------------------------------
if "chat_aberto" not in st.session_state:
    st.session_state.chat_aberto = True  # Inicia aberto para visualização

if "mensagens" not in st.session_state:
    st.session_state.mensagens = [
        {
            "role": "assistant",
            "content": "Olá! Sou o **Copilot Analítico da AdventureWorks**.<br>Posso consultar em tempo real as tabelas da camada **Marts** no Databricks.<br><br>💡 *Ex: 'Qual o faturamento total e lucro bruto?' ou 'Top 5 produtos B2B?'*",
            "sql": None,
            "dados": None,
        }
    ]

# -----------------------------------------------------------------------------
# 4. Conteúdo da Página Principal (Portal Executivo de Fundo)
# -----------------------------------------------------------------------------
st.title("🚴 AdventureWorks Analytics Platform")
st.markdown(
    "### Arquitetura Lakehouse & Governança de Dados (dbt + Databricks Unity Catalog)"
)

col1, col2, col3, col4 = st.columns(4)
with col1:
    st.markdown(
        """
    <div class="metric-card">
        <span style="color: #94A3B8; font-size: 12px; font-weight: 600;">CATÁLOGO UNITY CATALOG</span>
        <h3 style="color: #06B6D4; margin: 6px 0;">adventure_works</h3>
        <span style="color: #64748B; font-size: 12px;">Schema padrão: marts</span>
    </div>
    """,
        unsafe_allow_html=True,
    )

with col2:
    st.markdown(
        """
    <div class="metric-card">
        <span style="color: #94A3B8; font-size: 12px; font-weight: 600;">MODELAGEM ANALÍTICA</span>
        <h3 style="color: #3B82F6; margin: 6px 0;">Star Schema</h3>
        <span style="color: #64748B; font-size: 12px;">10 tabelas Gold (4 fatos e 6 dims)</span>
    </div>
    """,
        unsafe_allow_html=True,
    )

with col3:
    st.markdown(
        """
    <div class="metric-card">
        <span style="color: #94A3B8; font-size: 12px; font-weight: 600;">MOTOR DE QUERY</span>
        <h3 style="color: #10B981; margin: 6px 0;">SQL Warehouse</h3>
        <span style="color: #64748B; font-size: 12px;">Conexão segura serverless</span>
    </div>
    """,
        unsafe_allow_html=True,
    )

with col4:
    st.markdown(
        """
    <div class="metric-card">
        <span style="color: #94A3B8; font-size: 12px; font-weight: 600;">INTELIGÊNCIA ARTIFICIAL</span>
        <h3 style="color: #F43F5E; margin: 6px 0;">Gemini 3.6 Flash</h3>
        <span style="color: #64748B; font-size: 12px;">Text-to-SQL com Guardrails</span>
    </div>
    """,
        unsafe_allow_html=True,
    )

st.markdown("---")
st.info(
    "💡 **Dica**: Use o assistente flutuante no canto inferior direito para fazer perguntas em linguagem natural sobre qualquer domínio do negócio (Vendas, Clientes, Produção, Estoque, Compras e RH)."
)

# -----------------------------------------------------------------------------
# 5. Widget Flutuante do Chatbot (Inferior Direito)
# -----------------------------------------------------------------------------
# Botão para reabrir quando estiver minimizado
if not st.session_state.chat_aberto:
    st.markdown('<div class="floating-btn-container">', unsafe_allow_html=True)
    if st.button("💬 Perguntar à IA", key="btn_abrir_chat", type="primary"):
        st.session_state.chat_aberto = True
        st.rerun()
    st.markdown("</div>", unsafe_allow_html=True)

# Se o chat estiver aberto, renderiza a janela no canto inferior direito
if st.session_state.chat_aberto:
    # Cria duas colunas usando tupla: espaçador à esquerda e widget à direita
    col_main_spacer, col_chat_widget = st.columns((3, 2))
    with col_chat_widget:
        with st.container(border=True):
            # Cabeçalho do Widget com título e botão fechar
            c_title, c_close = st.columns((5, 1))
            with c_title:
                st.markdown(
                    "🤖 **AdventureWorks Copilot** <span style='color: #10B981; font-size: 11px;'>● Online</span>",
                    unsafe_allow_html=True,
                )
            with c_close:
                if st.button("✖", key="btn_fechar_chat", help="Minimizar Assistente"):
                    st.session_state.chat_aberto = False
                    st.rerun()

            st.caption(
                "Conectado ao Databricks Unity Catalog (`adventure_works.marts`)"
            )
            st.divider()

            # Área rolável das mensagens
            chat_container = st.container(height=380)
            with chat_container:
                for msg in st.session_state.mensagens:
                    if msg["role"] == "user":
                        st.markdown(
                            f"<div class='msg-user'>{msg['content']}</div>",
                            unsafe_allow_html=True,
                        )
                    else:
                        st.markdown(
                            f"<div class='msg-bot'>{msg['content']}</div>",
                            unsafe_allow_html=True,
                        )
                        if msg.get("sql"):
                            with st.expander("🔍 Ver SQL Executado"):
                                st.code(msg["sql"], language="sql")
                        if (
                            msg.get("dados") is not None
                            and isinstance(msg["dados"], pd.DataFrame)
                            and not msg["dados"].empty
                        ):
                            with st.expander("📋 Ver Tabela de Dados"):
                                st.dataframe(msg["dados"], use_container_width=True)

            # Formulário de entrada no rodapé da janela
            with st.form(key="form_chat_widget", clear_on_submit=True):
                c_input, c_send = st.columns((5, 1))
                with c_input:
                    pergunta = st.text_input(
                        "Digite sua dúvida...",
                        placeholder="Ex: Top 5 clientes em receita?",
                        label_visibility="collapsed",
                    )
                with c_send:
                    enviado = st.form_submit_button("➤")

            if enviado and pergunta.strip():
                st.session_state.mensagens.append(
                    {"role": "user", "content": pergunta, "sql": None, "dados": None}
                )

                with st.spinner("🧠 Consultando Databricks..."):
                    resultado = responder_pergunta(pergunta)

                st.session_state.mensagens.append(
                    {
                        "role": "assistant",
                        "content": resultado["resposta"],
                        "sql": resultado.get("sql"),
                        "dados": resultado.get("dados"),
                    }
                )
                st.rerun()

            if st.button("🗑️ Limpar histórico", use_container_width=True):
                st.session_state.mensagens = [
                    {
                        "role": "assistant",
                        "content": "Histórico limpo! Como posso ajudar você agora?",
                        "sql": None,
                        "dados": None,
                    }
                ]
                st.rerun()