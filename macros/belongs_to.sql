{% macro belongs_to(values) -%}

    __COLUMN_NAME__ in ({{ values | join(", ") }})

{%- endmacro %}
