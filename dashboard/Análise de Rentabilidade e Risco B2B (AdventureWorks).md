# Análise de Rentabilidade e Risco B2B (AdventureWorks)

## Resumo do Projeto
Dashboard executivo desenvolvido para monitorar a saúde financeira e a inadimplência de uma carteira de clientes B2B. O objetivo principal é dar visibilidade imediata ao volume de receita em risco crítico, permitindo ações proativas de cobrança e proteção do fluxo de caixa.

## Arquitetura e Engenharia de Dados
O grande diferencial deste projeto não está apenas na visualização, mas na esteira de dados (ELT) construída por trás da tela, seguindo as melhores práticas do mercado de Analytics Engineering:

* **Stack Tecnológico:** SQL Server, dbt Core, Python e Power BI.
* **Modelagem Dimensional:** Criação de um *Star Schema* rigoroso, substituindo tabelas "flat" por uma estrutura otimizada de Fato e Dimensões.
* **Camadas Staging e Marts:** Os dados brutos foram higienizados e padronizados em uma camada de *Staging* antes da aplicação das regras de negócio complexas na camada *Ouro (Marts)*.
* **Isolamento de Regras de Negócio:** Colunas críticas para a análise, como a Segmentação de Mercado (`COD_GRUPO`) e a Régua de Risco (`FAIXA_INAD`), foram desenvolvidas e mantidas de forma estritamente independente no motor SQL, garantindo governança e facilitando manutenções futuras.
* **Data Mocking Avançado:** Implementação de simulações lógicas diretamente no código dbt para injetar cenários de atraso reais na base de dados utópica de testes da Microsoft, validando a assertividade das fórmulas DAX.

## Design Visual e Apresentação de Indicadores
A camada visual foi projetada com foco na experiência do usuário executivo (UI/UX), utilizando princípios minimalistas para direcionar a tomada de decisão:

* **Paleta Semântica de Risco:** Aplicação de cores intencionais nos visuais (tons de alerta para *Risco Crítico* e *Atraso Leve*, contrastando com tons neutros para o faturamento *Em dia*). Isso remove a poluição visual e foca a atenção imediatamente no gargalo financeiro.
* **Ordenação Lógica (Sorting) via Banco:** A sequência de severidade do risco (1, 2 e 3) foi estruturada nativamente na arquitetura de dados (dbt). Isso garante que todos os gráficos empilhados e de evolução temporal obedeçam rigorosamente à lógica de negócio, sem depender de ajustes manuais no Power BI.
* **Estética Minimalista (Clean UI):** Background projetado para criar um efeito de containers flutuantes (cards). A remoção de bordas e fundos dos gráficos maximiza a clareza da leitura dos três KPIs principais: Receita Total, Receita em Risco Crítico e % de Receita em Risco.