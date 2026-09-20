# 📖 Dicionário de Dados & Catálogo Técnico — AdventureWorks Analytics

Este documento serve como o **Dicionário de Dados Oficial** da plataforma de dados **AdventureWorks**, hospedada no **Databricks Unity Catalog** e modelada via **dbt**. Foi projetado para que engenheiros de dados, analistas de BI, cientistas de dados e novos desenvolvedores compreendam instantaneamente a estrutura, a linhagem, os tipos de dados e a regra de negócio de cada tabela e coluna.

---

## 🧭 Sumário de Navegação Rápida

- [1. Padrões de Engenharia & Nomenclatura](#1-padrões-de-engenharia--nomenclatura)
- [2. Camada Gold (Marts) — Consumo Analítico](#2-camada-gold-marts--consumo-analítico)
  - [Fato: sales (Vendas & Faturamento)](#fato-sales)
  - [Fato: work_orders (Manufatura & Produção)](#fato-work_orders)
  - [Fato: purchases (Compras & Fornecedores)](#fato-purchases)
  - [Fato: inventory_snapshots (Estoque & Armazém)](#fato-inventory_snapshots)
  - [Dimensão: products (Catálogo de Produtos)](#dimensão-products)
  - [Dimensão: customers (Clientes B2C e B2B)](#dimensão-customers)
  - [Dimensão: dates (Calendário Analítico)](#dimensão-dates)
  - [Dimensão: sales_reps (Equipe Comercial)](#dimensão-sales_reps)
  - [Dimensão: vendors (Fornecedores)](#dimensão-vendors)
  - [Dimensão: employees (Recursos Humanos)](#dimensão-employees)
- [3. Camada Silver (Intermediate) — Regras de Negócio](#3-camada-silver-intermediate--regras-de-negócio)
- [4. Camada Silver (Staging) — Views Padronizadas](#4-camada-silver-staging--views-padronizadas)
- [5. Camada Bronze (Raw) — Origem dos Dados](#5-camada-bronze-raw--origem-dos-dados)

---

## 1. Padrões de Engenharia & Nomenclatura

- **Três Níveis de Namespace**: `catalogo.schema.tabela` (Ex: `adventure_works.marts.sales`).
- **Padrão de Colunas**: Estritamente em `snake_case`.
- **Chaves de Identificação**:
  - `*_id`: Chaves primárias de negócio e chaves substitutas inteiras.
  - `*_date_key`: Chaves numéricas de data formatadas como `YYYYMMDD` (compatíveis com a dimensão calendário).
  - `is_*`: Flags booleanas (`true` ou `false`).
  - `*_amount`: Valores financeiros expressos em moeda corrente (`DECIMAL(18,4)`).
  - `*_quantity` / `*_qty`: Quantidades físicas ou volumétricas.
  - `*_percentage` / `*_pct`: Taxas percentuais em decimais (ex: `0.1500` = 15%).

---

## 2. Camada Gold (Marts) — Consumo Analítico

> **Schema**: `adventure_works.marts`  
> **Formato**: Tabelas físicas Delta Lake  
> **Objetivo**: Atender diretamente ao Power BI, ferramentas de BI e consultas ad-hoc com alta performance.

---

### Fato: `sales`
- **Finalidade**: Registra todas as transações comerciais detalhadas por item faturado.
- **Grão**: 1 linha por item de pedido de venda (`sales_order_detail_id`).

| Coluna | Tipo | Nulável | Descrição Técnica & Regra de Negócio |
| :--- | :--- | :---: | :--- |
| `sales_order_detail_id` | `INT` | Não | **PK**. Identificador único da linha do item de pedido. |
| `sales_order_id` | `INT` | Não | Identificador do cabeçalho do pedido de venda. |
| `sales_order_number` | `STRING` | Sim | Código alfanumérico visível do pedido (ex: `SO43659`). |
| `order_date_key` | `INT` | Sim | **FK**. Chave de data do pedido no formato `YYYYMMDD` ligada à `dates`. |
| `due_date_key` | `INT` | Sim | **FK**. Chave de data de vencimento financeiro ligada à `dates`. |
| `ship_date_key` | `INT` | Sim | **FK**. Chave de data de expedição física ligada à `dates`. |
| `product_id` | `INT` | Sim | **FK**. Identificador do produto vendido ligado à `products`. |
| `customer_id` | `INT` | Sim | **FK**. Identificador do cliente ligado à `customers`. |
| `sales_person_id` | `INT` | Sim | **FK**. Identificador do vendedor ligado à `sales_reps` (`-1` para e-commerce). |
| `territory_id` | `INT` | Sim | **FK**. Território de venda originador. |
| `bill_to_address_id` | `INT` | Sim | Identificador do endereço de cobrança do cliente. |
| `ship_to_address_id` | `INT` | Sim | Identificador do endereço de entrega das mercadorias. |
| `ship_method_id` | `INT` | Sim | Identificador da transportadora/modalidade de envio. |
| `special_offer_id` | `INT` | Sim | Identificador da promoção ou campanha de desconto aplicada. |
| `order_status_code` | `INT` | Sim | Código de status: `1`=Processando, `2`=Aprovado, `5`=Enviado, `6`=Cancelado. |
| `is_online_order` | `BOOLEAN` | Sim | `true` se a venda ocorreu no e-commerce; `false` se foi via revenda/loja. |
| `sales_channel` | `STRING` | Sim | Canal de atendimento: `'Digital (E-commerce)'` ou `'Físico / Revenda'`. |
| `sales_reasons_list` | `STRING` | Sim | Motivos de compra declarados pelo cliente concatenados sem duplicar linhas. |
| `order_quantity` | `INT` | Sim | Quantidade de unidades físicas vendidas do produto. |
| `unit_price` | `DECIMAL(18,4)` | Sim | Preço unitário bruto praticado na venda. |
| `unit_price_discount` | `DECIMAL(18,4)` | Sim | Percentual de desconto concedido por unidade (`0.00` a `1.00`). |
| `unit_standard_cost` | `DECIMAL(18,4)` | Sim | Custo contábil padrão unitário do produto na data da transação. |
| `gross_amount` | `DECIMAL(18,4)` | Sim | Faturamento bruto: `order_quantity * unit_price`. |
| `discount_amount` | `DECIMAL(18,4)` | Sim | Valor monetário do desconto: `gross_amount * unit_price_discount`. |
| `net_amount` | `DECIMAL(18,4)` | Sim | **Faturamento Líquido (Receita)**: `gross_amount - discount_amount`. |
| `total_cost_amount` | `DECIMAL(18,4)` | Sim | **CPV**: Custo total do produto: `order_quantity * unit_standard_cost`. |
| `gross_profit_amount` | `DECIMAL(18,4)` | Sim | **Lucro Bruto**: `net_amount - total_cost_amount`. |
| `gross_margin_percentage` | `DECIMAL(10,4)` | Sim | **Margem Bruta %**: `(net_amount - total_cost_amount) / net_amount`. |

---

### Fato: `work_orders`
- **Finalidade**: Rastreamento da manufatura, controle de custos fabris e sucateamento.
- **Grão**: 1 linha por ordem de produção (`work_order_id`).

| Coluna | Tipo | Nulável | Descrição Técnica & Regra de Negócio |
| :--- | :--- | :---: | :--- |
| `work_order_id` | `INT` | Não | **PK**. Número sequencial da ordem de fabricação. |
| `start_date_key` | `INT` | Sim | **FK**. Data de início da fabricação (`YYYYMMDD`). |
| `end_date_key` | `INT` | Sim | **FK**. Data real de conclusão da fabricação (`YYYYMMDD`). |
| `due_date_key` | `INT` | Sim | **FK**. Data prometida para conclusão da produção (`YYYYMMDD`). |
| `product_id` | `INT` | Sim | **FK**. Produto fabricado ligado à `products`. |
| `scrap_reason_id` | `INT` | Sim | Identificador do motivo de sucata (`-1` se sem perdas). |
| `scrap_reason_name` | `STRING` | Sim | Descrição do defeito ou causa de refugo de material. |
| `production_cycle_days` | `INT` | Sim | Tempo de ciclo: dias decorridos entre início e conclusão da ordem. |
| `is_produced_on_time` | `BOOLEAN` | Sim | `true` se `end_date <= due_date` (produção pontual dentro do prazo). |
| `total_operations_count`| `LONG` | Sim | Quantidade de postos/etapas de roteiro fabril executados. |
| `order_quantity` | `INT` | Sim | Volume total de peças planejadas na ordem. |
| `stocked_quantity` | `INT` | Sim | Volume de peças aprovadas e estocadas com sucesso no armazém. |
| `scrapped_quantity` | `INT` | Sim | Volume de peças perdidas, defeituosas ou descartadas no processo. |
| `scrap_rate_percentage` | `DECIMAL(21,15)`| Sim | **Taxa de Refugo %**: `scrapped_quantity / order_quantity`. |
| `total_actual_resource_hours` | `DECIMAL(20,4)` | Sim | Total de horas de mão-de-obra e máquina consumidas na produção. |
| `total_planned_cost` | `DECIMAL(28,4)` | Sim | Custo fabril padrão orçado para a ordem. |
| `total_actual_cost` | `DECIMAL(28,4)` | Sim | Custo fabril real apurado após o encerramento da ordem. |
| `cost_variance_amount` | `DECIMAL(18,4)` | Sim | Desvio de custo: `total_actual_cost - total_planned_cost`. |

---

### Fato: `purchases`
- **Finalidade**: Registro de aquisições de matéria-prima e insumos de fornecedores externos.
- **Grão**: 1 linha por item de pedido de compra (`purchase_order_detail_id`).

| Coluna | Tipo | Nulável | Descrição Técnica & Regra de Negócio |
| :--- | :--- | :---: | :--- |
| `purchase_order_detail_id` | `INT` | Não | **PK**. Identificador único da linha do pedido de compra. |
| `purchase_order_id` | `INT` | Sim | Identificador do cabeçalho da ordem de compra. |
| `order_date_key` | `INT` | Sim | **FK**. Data de emissão da compra ligada à `dates`. |
| `ship_date_key` | `INT` | Sim | **FK**. Data de despacho do fornecedor ligada à `dates`. |
| `due_date_key` | `INT` | Sim | **FK**. Data de entrega acordada com o fornecedor ligada à `dates`. |
| `vendor_id` | `INT` | Sim | **FK**. Fornecedor contratado ligado à `vendors`. |
| `product_id` | `INT` | Sim | **FK**. Peça/insumo adquirido ligado à `products`. |
| `buyer_employee_id` | `INT` | Sim | Comprador responsável pela negociação. |
| `ship_method_id` | `INT` | Sim | Transportadora contratada para o frete. |
| `order_status_code` | `INT` | Sim | Status da compra (`1`=Pendente, `2`=Aprovado, `4`=Concluído). |
| `order_status_description` | `STRING` | Sim | Descrição textual do status da compra. |
| `is_delivered_on_time` | `BOOLEAN` | Sim | Indicador de pontualidade: `true` se entregue antes ou no prazo acordado. |
| `order_quantity` | `INT` | Sim | Quantidade de itens encomendados no pedido. |
| `received_quantity` | `DECIMAL(10,2)` | Sim | Quantidade de peças fisicamente descarregadas na doca. |
| `rejected_quantity` | `DECIMAL(10,2)` | Sim | Quantidade de peças reprovadas na inspeção de controle de qualidade. |
| `stocked_quantity` | `DECIMAL(10,2)` | Sim | Quantidade líquida aprovada para estoque: `received - rejected`. |
| `rejection_rate_percentage` | `DECIMAL(21,15)`| Sim | **Taxa de Não Conformidade %**: `rejected_quantity / order_quantity`. |
| `unit_price` | `DECIMAL(18,4)` | Sim | Preço unitário contratado por peça. |
| `line_subtotal_amount` | `DECIMAL(18,4)` | Sim | **Gasto Total da Linha**: `order_quantity * unit_price`. |

---

### Fato: `inventory_snapshots`
- **Finalidade**: Posição e valorização do estoque físico em cada posto de armazenagem.
- **Grão**: 1 linha por produto e posto de armazenagem (`product_id`, `location_id`).

| Coluna | Tipo | Nulável | Descrição Técnica & Regra de Negócio |
| :--- | :--- | :---: | :--- |
| `product_id` | `INT` | Não | **PK/FK**. Identificador do produto em estoque ligado à `products`. |
| `location_id` | `INT` | Não | **PK**. Identificador do armazém ou centro de trabalho físico. |
| `shelf_code` | `STRING` | Sim | Letra ou código da prateleira física no armazém (ex: `'A'`, `'B'`). |
| `bin_number` | `INT` | Sim | Número do escaninho/gaveta na prateleira. |
| `stock_health_status` | `STRING` | Sim | Diagnóstico: `'Crítico (Abaixo da Segurança)'`, `'Alerta (Ponto de Reposição)'` ou `'Regular'`. |
| `is_below_reorder_point` | `BOOLEAN` | Sim | Flag que dispara necessidade imediata de ressuprimento. |
| `stock_quantity` | `INT` | Sim | Saldo físico disponível do produto no local. |
| `safety_stock_level` | `INT` | Sim | Estoque mínimo de segurança definido pela engenharia. |
| `reorder_point_level` | `INT` | Sim | Ponto de reposição: limite que exige nova ordem de compra/produção. |
| `unit_standard_cost` | `DECIMAL(18,4)` | Sim | Custo unitário contábil do item. |
| `total_stock_cost_value`| `DECIMAL(18,4)` | Sim | **Capital Total em Estoque**: `stock_quantity * unit_standard_cost`. |

---

### Dimensão: `products`
- **Finalidade**: Catálogo mestre de produtos com hierarquia desnormalizada e atributos físicos.
- **Grão**: 1 linha por SKU (`product_id`).

| Coluna | Tipo | Nulável | Descrição Técnica |
| :--- | :--- | :---: | :--- |
| `product_id` | `INT` | Não | **PK**. Identificador único do produto. |
| `product_number` | `STRING` | Sim | Código alfanumérico SKU (ex: `'BK-R93R-62'`). |
| `product_name` | `STRING` | Sim | Nome comercial oficial do produto. |
| `category_name` | `STRING` | Sim | Macrocategoria: `'Bikes'`, `'Components'`, `'Clothing'`, `'Accessories'`. |
| `subcategory_name` | `STRING` | Sim | Subcategoria de detalhamento (ex: `'Mountain Bikes'`, `'Helmets'`). |
| `product_model_name` | `STRING` | Sim | Nome da família conceitual de engenharia (ex: `'Road-150'`). |
| `color_name` | `STRING` | Sim | Cor predominante do item. |
| `product_line_code` | `STRING` | Sim | Linha: `'R'` (Road), `'M'` (Mountain), `'T'` (Touring), `'S'` (Standard). |
| `class_code` | `STRING` | Sim | Classe de acabamento: `'H'` (High), `'M'` (Medium), `'L'` (Low). |
| `style_code` | `STRING` | Sim | Estilo: `'W'` (Feminino), `'M'` (Masculino), `'U'` (Unissex). |
| `is_manufactured_in_house` | `BOOLEAN` | Sim | `true` se fabricado internamente; `false` se comprado pronto. |
| `is_finished_goods` | `BOOLEAN` | Sim | `true` se elegível para venda direta a clientes. |
| `is_currently_sold` | `BOOLEAN` | Sim | `true` se o produto está ativo no catálogo corrente de vendas. |
| `safety_stock_level` | `INT` | Sim | Estoque mínimo de segurança. |
| `reorder_point_level` | `INT` | Sim | Ponto de disparo de reposição. |
| `days_to_manufacture` | `INT` | Sim | Tempo médio de ciclo de manufatura em dias úteis. |
| `standard_cost` | `DECIMAL(18,4)` | Sim | Custo padrão de fabricação ou aquisição. |
| `list_price` | `DECIMAL(18,4)` | Sim | Preço de tabela sugerido para venda. |
| `standard_margin_amount` | `DECIMAL(18,4)` | Sim | Margem unitária teórica: `list_price - standard_cost`. |
| `standard_margin_percentage` | `DECIMAL(10,4)` | Sim | Percentual de margem teórica: `standard_margin_amount / list_price`. |
| `size` | `STRING` | Sim | Tamanho ou dimensão física (ex: `'48'`, `'L'`). |
| `weight` | `DECIMAL(10,2)` | Sim | Peso líquido do produto. |
| `sell_start_date` | `DATE` | Sim | Data em que o produto foi lançado comercialmente. |
| `sell_end_date` | `DATE` | Sim | Data em que o produto deixou de ser comercializado. |
| `discontinued_date` | `DATE` | Sim | Data oficial de obsolescência do produto. |

---

### Dimensão: `customers`
- **Finalidade**: Visão unificada de clientes pessoa física (B2C) e clientes corporativos/revendas (B2B).
- **Grão**: 1 linha por cliente (`customer_id`).

| Coluna | Tipo | Nulável | Descrição Técnica |
| :--- | :--- | :---: | :--- |
| `customer_id` | `INT` | Não | **PK**. Identificador único da conta do cliente. |
| `customer_account_number` | `STRING` | Sim | Código da conta contábil do cliente (ex: `'AW00029847'`). |
| `customer_type` | `STRING` | Sim | Classificação da carteira: `'Individual (B2C)'` ou `'Store (B2B)'`. |
| `customer_name` | `STRING` | Sim | Nome completo da pessoa física ou Razão Social da loja. |
| `email_address` | `STRING` | Sim | Endereço de e-mail principal do cliente ou contato comercial. |
| `phone_number` | `STRING` | Sim | Telefone principal de contato. |
| `territory_name` | `STRING` | Sim | Território comercial atribuído (ex: `'Northwest'`, `'France'`). |
| `territory_group` | `STRING` | Sim | Macrorregião: `'North America'`, `'Europe'`, `'Pacific'`. |
| `city_name` | `STRING` | Sim | Cidade de localização do endereço principal. |
| `state_province_code` | `STRING` | Sim | Sigla do estado ou província (ex: `'WA'`, `'CA'`). |
| `state_province_name` | `STRING` | Sim | Nome por extenso do estado ou província. |
| `country_region_name` | `STRING` | Sim | Nome oficial do país do cliente. |

---

### Dimensão: `dates`
- **Finalidade**: Calendário corporativo contínuo para suporte a cálculos de inteligência temporal no Power BI.
- **Grão**: 1 linha por dia civil (01/01/2010 a 31/12/2026).

| Coluna | Tipo | Nulável | Descrição Técnica |
| :--- | :--- | :---: | :--- |
| `date_key` | `INT` | Não | **PK**. Chave inteira no formato `YYYYMMDD` (ex: `20260906`). |
| `calendar_date` | `DATE` | Sim | Data no formato ISO `YYYY-MM-DD`. |
| `calendar_year` | `INT` | Sim | Ano civil numérico (ex: `2026`). |
| `calendar_quarter` | `INT` | Sim | Trimestre do ano (`1`, `2`, `3`, `4`). |
| `calendar_month` | `INT` | Sim | Mês do ano (`1` a `12`). |
| `month_name` | `STRING` | Sim | Nome por extenso do mês (ex: `'Setembro'`). |
| `month_year_code` | `STRING` | Sim | Código abreviado de mês e ano para eixos de gráficos (ex: `'Sep-26'`). |
| `day_of_month` | `INT` | Sim | Dia do mês (`1` a `31`). |
| `day_of_week` | `INT` | Sim | Dia da semana numérico (`1`=Domingo a `7`=Sábado). |
| `day_name` | `STRING` | Sim | Nome por extenso do dia da semana (ex: `'Domingo'`). |
| `is_weekend` | `BOOLEAN` | Sim | `true` se sábado ou domingo; `false` para dias úteis. |

---

### Dimensão: `sales_reps`
- **Finalidade**: Representantes e vendedores comerciais com estrutura hierárquica e metas.
- **Grão**: 1 linha por vendedor (`sales_person_id`).

| Coluna | Tipo | Nulável | Descrição Técnica |
| :--- | :--- | :---: | :--- |
| `sales_person_id` | `INT` | Não | **PK**. Identificador do representante comercial. |
| `sales_person_name` | `STRING` | Sim | Nome completo do vendedor. |
| `job_title` | `STRING` | Sim | Título oficial do cargo ocupado na empresa. |
| `hire_date` | `DATE` | Sim | Data de contratação do profissional. |
| `is_current` | `BOOLEAN` | Sim | `true` se o profissional está atualmente ativo no quadro. |
| `territory_name` | `STRING` | Sim | Território comercial sob responsabilidade do vendedor. |
| `territory_group` | `STRING` | Sim | Macrorregião de atuação. |
| `sales_quota_amount` | `DECIMAL(18,4)` | Sim | Cota periódica de vendas estipulada em R$. |
| `bonus_amount` | `DECIMAL(18,4)` | Sim | Valor monetário de bônus por atingimento de metas. |
| `commission_percentage` | `DECIMAL(5,4)` | Sim | Percentual de comissão sobre vendas faturadas. |

---

### Dimensão: `vendors`
- **Finalidade**: Cadastro de fornecedores homologados de matérias-primas e produtos prontos.
- **Grão**: 1 linha por fornecedor (`vendor_id`).

| Coluna | Tipo | Nulável | Descrição Técnica |
| :--- | :--- | :---: | :--- |
| `vendor_id` | `INT` | Não | **PK**. Identificador único da empresa fornecedora. |
| `vendor_account_number` | `STRING` | Sim | Código de faturamento/conta corporativa do fornecedor. |
| `vendor_name` | `STRING` | Sim | Razão social ou nome fantasia oficial do fornecedor. |
| `credit_rating` | `INT` | Sim | Classificação de risco de crédito de `1` (melhor) a `5` (pior). |
| `credit_rating_description` | `STRING` | Sim | Diagnóstico: `'Excelente'`, `'Muito Bom'`, `'Regular'`, `'Atenção'`, `'Risco Alto'`. |
| `is_preferred_vendor` | `BOOLEAN` | Sim | `true` se o parceiro possui status prioritário de compra. |
| `is_active` | `BOOLEAN` | Sim | `true` se o fornecedor está ativo para emissão de novos pedidos. |
| `city_name` | `STRING` | Sim | Cidade sede do fornecedor. |
| `state_province_name` | `STRING` | Sim | Estado ou província da sede do fornecedor. |
| `country_region_name` | `STRING` | Sim | País sede do fornecedor. |

---

### Dimensão: `employees`
- **Finalidade**: Força de trabalho corporativa, alocação departamental, turnos e remuneração.
- **Grão**: 1 linha por colaborador ativo (`employee_id`).

| Coluna | Tipo | Nulável | Descrição Técnica |
| :--- | :--- | :---: | :--- |
| `employee_id` | `INT` | Não | **PK**. Identificador único do colaborador. |
| `employee_name` | `STRING` | Sim | Nome completo do colaborador. |
| `login_id` | `STRING` | Sim | Login corporativo de rede (ex: `adventure-works\ken0`). |
| `job_title` | `STRING` | Sim | Cargo ocupado pelo colaborador na estrutura da empresa. |
| `gender_code` | `STRING` | Sim | Gênero: `'M'` (Masculino) ou `'F'` (Feminino). |
| `marital_status_code` | `STRING` | Sim | Estado civil: `'M'` (Casado) ou `'S'` (Solteiro). |
| `department_name` | `STRING` | Sim | Nome do departamento em que o colaborador atua. |
| `department_group_name` | `STRING` | Sim | Divisão corporativa executiva superior. |
| `shift_name` | `STRING` | Sim | Turno de trabalho alocado: `'Day'`, `'Evening'`, `'Night'`. |
| `department_start_date` | `DATE` | Sim | Data de início de atuação no departamento atual. |
| `hire_date` | `DATE` | Sim | Data de admissão do colaborador na empresa. |
| `tenure_years` | `DECIMAL(15,2)` | Sim | Tempo de casa acumulado em anos (`datediff / 365.25`). |
| `is_salaried` | `BOOLEAN` | Sim | `true` se assalariado mensal; `false` se horista. |
| `is_current` | `BOOLEAN` | Sim | `true` se o colaborador está ativo na empresa. |
| `current_pay_rate` | `DECIMAL(18,4)` | Sim | Taxa salarial ou valor hora vigente mais recente. |
| `current_pay_frequency_code` | `INT` | Sim | Frequência de pagamento: `1` (Mensal) ou `2` (Quinzenal). |
| `vacation_hours` | `INT` | Sim | Saldo de horas de férias acumuladas disponíveis. |
| `sick_leave_hours` | `INT` | Sim | Saldo de horas de licença médica disponíveis. |

---

## 3. Camada Silver (Intermediate) — Regras de Negócio

> **Schema**: `adventure_works.intermediate`  
> **Formato**: Views lógicas  
> **Objetivo**: Desacoplar regras de negócio complexas das tabelas finais, garantindo reutilização e rastreabilidade.

| Modelo Intermediate | Tabelas de Origem Utilizadas | Problema Analítico / Regra de Negócio Resolvida |
| :--- | :--- | :--- |
| **`int_locations_joined`** | `address`, `state_province`, `country_region` | Consolida o endereço físico completo (logradouro, cidade, estado e país) em uma entidade única. |
| **`int_products_enriched`** | `product`, `product_subcategory`, `product_category`, `product_model` | Elimina a modelagem snowflake de produtos, integrando categorias, subcategorias e famílias de engenharia. |
| **`int_customers_unified`** | `customer`, `person`, `store`, `email_address`, `person_phone`, `sales_territory` | Unifica pessoas físicas e lojas, aplicando lógica de deduplicação de contatos para impedir fan-out de linhas. |
| **`int_sales_reps_enriched`** | `sales_person`, `employee`, `person`, `sales_territory` | Cruza dados funcionais do vendedor com sua cota de vendas e limites territoriais. |
| **`int_sales_order_reasons_aggregated`** | `sales_order_header_sales_reason`, `sales_reason` | Resolve relacionamento N:N agregando motivos de compra em string única delimitada por vírgula por pedido. |
| **`int_vendors_enriched`** | `vendor`, `business_entity_address`, `int_locations_joined` | Padroniza o cadastro de fornecedores associando a localização geográfica da sede. |
| **`int_inventory_stock_status`** | `product_inventory`, `int_products_enriched`, `location` | Avalia o valor financeiro do estoque e sinaliza alertas de risco de ruptura (Abaixo do Estoque de Segurança e Ponto de Reposição). |
| **`int_work_orders_enriched`** | `work_order`, `work_order_routing`, `scrap_reason` | Agrega horas de máquina e custos reais da esteira fabril ao grão da ordem de serviço, calculando variância e refugo. |
| **`int_inventory_transactions_unioned`** | `transaction_history`, `transaction_history_archive` | Realiza `UNION ALL` entre o histórico corrente e o arquivo morto de movimentações de estoque. |
| **`int_employees_current_assignment`** | `employee`, `employee_department_history`, `employee_pay_history`, `department`, `shift`, `person` | Filtra o departamento ativo e a remuneração vigente mais recente de cada colaborador via window functions (`row_number()`). |
| **`int_purchase_order_lines_enriched`** | `purchase_order_detail`, `purchase_order_header`, `int_vendors_enriched`, `ship_method` | Pré-calcula pontualidade de entrega (*OTIF*), taxas de refugo físico na doca e gastos com compras por item. |
| **`int_sales_order_lines_enriched`** | `sales_order_detail`, `sales_order_header`, `int_products_enriched`, `int_sales_order_reasons_aggregated` | Consolida faturamento bruto, descontos, receita líquida, CPV e margens brutas no grão do item vendido. |

---

## 4. Camada Silver (Staging) — Views Padronizadas

> **Schema**: `adventure_works.staging`  
> **Formato**: Views lógicas normalizadas  
> **Objetivo**: Limpeza sintática, tipagem estrita com `try_cast`, padronização *snake_case* e remoção de caracteres inválidos.

| Domínio de Negócio | Quantidade de Views | Principais Entidades e Cobertura |
| :--- | :---: | :--- |
| **Vendas (`sales`)** | 19 | `sales_order_header`, `sales_order_detail`, `customer`, `store`, `sales_person`, `sales_territory`, `sales_reason`, `special_offer`, `currency`, `credit_card`. |
| **Manufatura (`production`)** | 25 | `product`, `product_category`, `product_subcategory`, `product_model`, `product_inventory`, `work_order`, `work_order_routing`, `bill_of_materials`, `scrap_reason`, `transaction_history`. |
| **Compras (`purchasing`)** | 5 | `purchase_order_header`, `purchase_order_detail`, `vendor`, `product_vendor`, `ship_method`. |
| **Pessoas (`person`)** | 13 | `person`, `address`, `state_province`, `country_region`, `address_type`, `business_entity`, `email_address`, `person_phone`, `phone_number_type`. |
| **RH (`humanresources`)** | 6 | `employee`, `department`, `employee_department_history`, `employee_pay_history`, `shift`, `job_candidate`. |
| **Sistema & Auditoria (`dbo`)** | 3 | `dbo_aw_build_version`, `dbo_database_log`, `dbo_error_log`. |

---

## 5. Camada Bronze (Raw) — Origem dos Dados

> **Schema**: `adventure_works.raw`  
> **Formato**: Tabelas Delta Lake com dados brutos  
> **Objetivo**: Cópia fiel 1:1 dos dados transacionais do banco de dados relacional OLTP original do AdventureWorks.