{# /*
  Ensure that a predicate fails. Basically the opposite of `test_spec`.
*/ #}

{% macro test_spec_fails(model, column_name, predicate) %}

   WITH failures AS (
     SELECT count(*) AS count_failures
     FROM ({{ spec.test_test(model, column_name, predicate) }})
   )

   -- If there are any failures we are successful, if there are no
   -- failures, then we are unsucessful
   SELECT * FROM failures WHERE count_failures = 0

{% endmacro %}
