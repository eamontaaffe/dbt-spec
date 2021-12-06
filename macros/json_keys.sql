{# /*

  The same as object_keys except it casts a string field to json
  before running.

*/ #}

{% macro json_keys(required=[], optional=[], closed=False) -%}

   {{
     return(
       object_keys(required=optional, optional=optional, closed=closed)
       | replace("__COLUMN_NAME__", "PARSE_JSON(__COLUMN_NAME__)"
     )
   }}

{%- endmacro %}
