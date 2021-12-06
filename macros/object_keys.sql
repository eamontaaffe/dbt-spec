{# /*

  Ensure that an object contains certain keys.

  {{ object_keys(required=['A'], optional=['B']) }}

  The column *must* contain the required keys. It may contain the
  optional keys. Objects are open by default, meaning that extra keys
  do not raise errors. If you would like a closed object use the key
  `closed=True`.

*/ #}

{% macro object_keys(required=[], optional=[], closed=False) -%}

  {% for key in required -%}

    ARRAY_CONTAINS('{{ key }}'::VARIANT, OBJECT_KEYS(__COLUMN_NAME__))

    {% if not loop.last %} AND {% endif %}

  {%- endfor %}

  {% if closed -%}

    {% set allowed = spec.prepare_keys(required + optional) %}

    AND ARRAY_SIZE({{
      spec.array_remove_many('OBJECT_KEYS(__COLUMN_NAME__)', allowed)
    }}) = 0

  {% endif %}

{%- endmacro %}

{% macro prepare_keys(xs) -%}

  {% if xs | length == 0 -%}

      {{ return([]) }}

  {%- else -%}

      {{ return(["'" ~ xs[0] ~ "'::VARIANT"] + spec.prepare_keys(xs[1:])) }}

  {%- endif %}

{%- endmacro %}
