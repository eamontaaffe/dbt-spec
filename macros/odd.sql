{% macro odd() -%}

   NOT {{ even() }}

{%- endmacro %}
