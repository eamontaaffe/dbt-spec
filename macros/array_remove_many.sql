{# /*

  Remove many values from an array. The first argument is the
  reference to the array column in SQL. The second argument is a Jinja
  array of values to be removed.

  {{ array_remove_many('array_construct(1, 2, 3)', [1, 2]) }}

*/ #}

{% macro array_remove_many(column_name, ys) -%}

  {% if ys | length == 0 -%}

    {{ column_name }}

  {%- else -%}

    {{ array_remove(array_remove_many(column_name, ys[1:]), ys[0]) }}

  {%- endif %}

{%- endmacro %}
