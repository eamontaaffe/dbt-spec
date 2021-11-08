# dbt-spec

**dbt-spec** is an extension package for
[dbt](https://github.com/fishtown-analytics/dbt) that allows you to
tests your data at runtime rather than afterwards.

Typically in dbt you would build a model _then_ run your tests. This
is the opposite order to what you might be used to in most
frameworks/languages. This makes it tricky to ensure correctness on
important models before they are published to production.

A common approach is to genereate a staging model, run the tests on
that model, then re-run the same model in production. This requires an
expensive secondary computation of the same model. It is also possible
that the underlying dataset may have changed, meaning that when the
model is run a second time the output may be different.

## Install

**dbt-spec** is currently in development. So if you would like to test
it out, please use the [git package
syntax](https://docs.getdbt.com/docs/building-a-dbt-project/package-management#git-packages).

```yaml
packages:
- git: "https://github.com/eamontaaffe/dbt-spec.git"
  revision: master
```

## How does it work?

Some functions in databases raise errors at runtime. For example, the
Snowflake `TO_BOOLEAN` function takes a string an converts it to a
boolean. This function may may throw an error if the string contains
something unexpected. This error stops the execution of the query

By leaning on this behaviour, we are able to "raise" an exception
ourselves at runtime. We can create a simple macro to insert this
behaviour into a model.

```sql
{% macro raise(message) -%}

   TO_BOOLEAN('{{ 'EXCEPTION: ' ~ message }}')

{%- endmacro %}
```

This will stop execution as long as the message is not 'true' or
'false'. Since we prefix every message with 'EXCEPTION' the input will
always fail.

Now that we have the ability to raise an exception we start to
construct predicate macros which we will use to test our data. Say we
wanted to ensure that a column only ever has even values, we can write
a macro `is_even` which will raise a runtime error unless our data
conforms.

```sql
{% macro is_even(name) -%}

   CASE
       WHEN {{ name }} % 2 = 0 THEN {{ name }}
       ELSE {{ raise(name ~ " is not even!") }}
   END

{%- endmacro %}
```

We can then use this macro in our models to enforce a _runtime_ column
constraint.

```sql
{{ config(materialized='table') }}

WITH source_data AS (

    SELECT 1 AS id
    UNION ALL
    SELECT 2 AS id

)

SELECT

  {{ is_even('id') }} AS id

FROM source_data
```

Since this model does _not_ contain even values, it will raise an
exception.

```
Completed with 1 error and 0 warnings:

Database Error in model my_first_dbt_model (models/example/my_first_dbt_model.sql)
  100037 (22018): Boolean value 'EXCEPTION: id is not even!' is not recognized
  compiled SQL at target/run/spec/models/example/my_first_dbt_model.sql
```

## Concepts

The **dbt-spec** package adds a few conveniences to the methods
described in the, [How does it work?](#how-does-it-work)
section. There are a few types of macros in this project, conditional
macros, combinator macros and everything else. Conditional macros are
designed to be composed together to create complex predicates that can
suit all your project's needs. The other macros are just there to
serve the conditionals and make them easy to work with.

### The `spec` macro

The `spec` macro wraps a conditional macro and handles the exception
throwing behind the scenes. A typical use of the `spec` macro looks
like this:

```sql
SELECT

    {{ spec(belongs_to([1, 2, 3]), 'foo') }} AS foo_even

FROM

    source
```

In this example `belongs_to([1, 2, 3])` is the conditional and the
column name is `foo`.

### Conditional macros

There are a whole lot of conditional macros shipped with the
package. You could even write your own if you can't find one to suit
your needs. All conditional macros return a boolean value. If the
value is `true` the test has passed, if the value is `false` the test
has failed.

The simplest conditional to check if a value is even may look like
this.

```sql
{% macro even() -%}

   __COLUMN_NAME__ % 2 = 0

{%- endmacro %}
```

Notice the `__COLUMN__NAME__` token. This will be replaced by the
name of the column at compile time.

### Combinator macros

Combinators are used to combine conditionals. They too will return a
boolean value when evaluated.

The simplest combinator is the `and` macro. This combines the output
of two combinators using the boolean operator `AND`. The
implementation looks like this.

```sql
{% macro and(x1, x2) -%}

   {{ x1 }} AND {{ x2 }}

{%- endmacro %}
```

Notice that we don't need to use the `__COLUMN_NAME__` token. The
values of `x1` and `x2` will already contain this value.

We can use combinators to create interesting predicates. For example
if we wanted to ensure that a value was even and belongs to a set we
can use the combinator `and` like so.

```sql
SELECT

  {{ spec(and(even(), belongs_to([1, 2, 3])), 'bar') }} AS bar

FROM source
```
