{{ config(materialized='table') }}

WITH source_data AS (

    SELECT 1 AS foo, 1 AS bar, 1 AS baz
    UNION ALL
    SELECT 2 AS foo, 2 AS bar, 2 AS baz
    UNION ALL
    SELECT 3 AS foo, 3 AS bar, 3 AS baz

)

SELECT

  {{ spec(even(), 'foo') }} AS foo_even,
  {{ spec(odd(), 'foo') }} AS foo_odd,
  {{ spec(belongs_to([1, 2, 3]), 'bar') }} AS bar,
  {{ spec(and(even(), belongs_to([1, 2, 3])), 'baz') }} AS baz

FROM source_data
