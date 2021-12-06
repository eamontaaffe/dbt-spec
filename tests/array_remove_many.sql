WITH tests AS (

  SELECT

    {{ array_remove_many('array_construct(1, 2, 3)', [2]) }}
      AS actual,

    array_construct(1, 3) AS expected

  UNION ALL

  SELECT

    {{ array_remove_many('array_construct(1, 2, 3)', []) }}
      AS actual,

    array_construct(1, 2, 3) AS expected

  UNION ALL

  SELECT

    {{ array_remove_many('array_construct(1, 2, 3)', [1, 2]) }}
      AS actual,

    array_construct(3) AS expected

)

SELECT

    *

FROM

    tests

WHERE

    NOT (actual IS NULL AND expected IS NULL)
    AND NOT COALESCE(actual = expected, FALSE)
