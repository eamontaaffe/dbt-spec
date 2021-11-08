{% macro and(x1, x2) -%}

   {{ x1 }} AND {{ x2 }}

{%- endmacro %}

{% macro or(x1, x2) -%}

   {{ x1 }} OR {{ x2 }}

{%- endmacro %}

{% macro belongs_to(values) -%}

    __COLUMN_NAME__ in ({{ values | join(", ") }})

{%- endmacro %}

{% macro even() -%}

   __COLUMN_NAME__ % 2 = 0

{%- endmacro %}

{% macro odd() -%}

   NOT {{ even() }}

{%- endmacro %}

{% macro spec(conditional, column_name) -%}

  CASE
    WHEN {{ conditional | replace("__COLUMN_NAME__", column_name) }} THEN {{ column_name }}
    ELSE {{ raise("Specification failed: " ~ conditional) }}
  END

{%- endmacro %}

{% macro raise(message) -%}

   {#-
     XXXX: A bit of a hack, but this will stop execution as long as
     the message is not 'true' or 'false'.
   -#}

   TO_BOOLEAN('{{ 'EXCEPTION: ' ~ message }}')

{%- endmacro %}
