{{ config(materialized='ephemeral') }}

SELECT 2 AS foo, parse_json('{"A": true}') AS bar
UNION
SELECT 4 AS foo, parse_json('{"A": false, "B": 1}') AS bar
UNION
SELECT 4 AS foo, parse_json('{"A": false, "C": "hello"}') AS bar
