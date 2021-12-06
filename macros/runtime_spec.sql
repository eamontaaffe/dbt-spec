{% macro runtime_spec(conditional, column_name) -%}

  CASE

  WHEN {{ conditional | replace("__COLUMN_NAME__", column_name) }}
  THEN {{ column_name }}

  WHEN {{ raise("Specification failed: " ~ conditional) }}
  THEN {{ column_name }}

  END

{%- endmacro %}

{% macro raise(message) -%}

   {#-
     XXXX: A bit of a hack, but this will stop execution as long as
     the message is not 'true' or 'false'.
   -#}

   TO_BOOLEAN('{{ 'EXCEPTION: ' ~ message }}')

{%- endmacro %}
