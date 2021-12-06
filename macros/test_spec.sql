{# /*
  Ensure that a predicate is true.
*/ #}

{% macro test_test(model, column_name, predicate) %}

   SELECT {{ column_name }}
   FROM {{ model }}
   WHERE NOT ({{ predicate | replace("__COLUMN_NAME__", column_name) }})

{% endmacro %}
