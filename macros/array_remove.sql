{% macro array_remove(xs, y) -%}

  {% set pos -%}

    ARRAY_POSITION({{ y }}, {{ xs }})

  {%- endset %}

  CASE
  WHEN {{ pos }} IS NULL THEN {{ xs }}
  ELSE
    ARRAY_CAT(
      ARRAY_SLICE({{ xs }}, 0, {{ pos }}),
      ARRAY_SLICE({{ xs }}, {{ pos }} + 1, ARRAY_SIZE({{ xs }}))
    )
  END

{%- endmacro %}
