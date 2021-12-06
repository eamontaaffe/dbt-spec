WITH tests AS (

  SELECT

    {{ array_remove('array_construct(1, 2, 3)', '2') }} AS actual,
    array_construct(1, 3) AS expected

  UNION ALL

  SELECT

    {{ array_remove('array_construct(1, 2, 3)', '1') }} AS actual,
    array_construct(2, 3) AS expected

  UNION ALL

  SELECT

    {{ array_remove('array_construct(1, 2, 3)', '3') }} AS actual,
    array_construct(1, 2) AS expected

  UNION ALL

  SELECT

    -- If the item is not present, it should return the original array
    {{ array_remove('array_construct(1, 2, 3)', '4') }} AS actual,
    array_construct(1, 2, 3) AS expected

  UNION ALL

  SELECT

    -- Only removes the first occurance of the value from the array.
    {{ array_remove('array_construct(1, 2, 3, 2)', '2') }} AS actual,
    array_construct(1, 3, 2) AS expected

  UNION ALL

  SELECT

    -- Should work with Jinja variables too
    {{ array_remove('array_construct(1, 2, 3)', 2) }} AS actual,
    array_construct(1, 3) AS expected

)

SELECT

    *

FROM

    tests

WHERE

    NOT (actual IS NULL AND expected IS NULL)
    AND NOT COALESCE(actual = expected, FALSE)
