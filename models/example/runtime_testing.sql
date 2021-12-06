{{ config(materialized='ephemeral') }}

WITH source_data AS (

  SELECT 2 AS foo
  UNION
  SELECT 4 AS foo

),

test_data AS (

  SELECT

    {{ runtime_spec(even(), 'foo') }} AS foo

  FROM source_data

)

SELECT * FROM source_data
