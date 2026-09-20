{% macro databricks__create_view_as(relation, sql) -%}
  create or replace view {{ relation }}
  as
    {{ sql }}
{%- endmacro %}

{% macro spark__create_view_as(relation, sql) -%}
  create or replace view {{ relation }}
  as
    {{ sql }}
{%- endmacro %}

{% macro default__create_view_as(relation, sql) -%}
  create or replace view {{ relation }}
  as
    {{ sql }}
{%- endmacro %}