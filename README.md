# dbt-spec

**dbt-spec** is an extension package for
[dbt](https://github.com/fishtown-analytics/dbt) based on [Clojure's
excellent spec package](https://clojure.org/guides/spec). In short,
`dbt-spec` is an expressive, powerful approach for type specification
and testing.

## Install

**dbt-spec** is currently in development. So if you would like to test
it out, please use the [git package
syntax](https://docs.getdbt.com/docs/building-a-dbt-project/package-management#git-packages).

```yaml
packages:
- git: "https://github.com/eamontaaffe/dbt-spec.git"
  revision: master
```

## Example

Say for instance you have a model and you want to ensure that:

- the column `foo` is positive
- the column `bar` is even
- the column `baz` is positive and even
- the column `qux` belongs to the set `1, 2, 3`
- the column `quux` is an object with the key `A` required and `B`
  optional

You would write a model like so:

```yaml
version: 2

models:
  - name: my_first_dbt_model
    columns:
      - name: foo
        tests:
          - spec.test:
              predicate: "{{ spec.positive() }}"
      - name: bar
        tests:
          - spec.test:
              predicate: "{{ spec.even() }}"
      - name: baz
        tests:
          - spec.test:
              predicate: "{{ spec.and(spec.positive(), spec.even()) }}"
      - name: qux
        tests:
          - spec.test:
              predicate: "{{ spec.belongs_to([1, 2, 3]) }}"
      - name: quux
        tests:
          - spec.test:
              predicate: "{{ spec.object_keys(required=['A'], optional=['B'] }}"
```

## Concepts

There are a few different types of macros in this project, conditional
macros, combinator macros and everything else. Conditional macros are
designed to be composed together to create complex predicates that can
suit all your project's needs. The other macros are just there to
serve the conditionals and make them easy to work with.

### The `spec` test

It all starts with the `spec` [generic
test](https://docs.getdbt.com/docs/building-a-dbt-project/tests#generic-tests). The
spec test is intended to wrap our conditional and combinator macros to
produce expressive specifications.

```yaml
version: 2

models:
  - name: foo
    columns:
      - name: bar
        tests:
          - spec.test:
              predicate: "{{ spec.and(spec.even(), spec.belongs_to([2, 3, 4])) }}"
```

In this example we have created a test for the `bar` column on the
`foo` model. The test says, this column should only contain even
numbers in the set `[1, 2, 3]`. For example, this table would pass the
test.

| id  | bar |
|-----|-----|
| `0` | `2` |
| `1` | `4` |
| `2` | `2` |

### Complex type specifications

The thing which `dbt-spec` really excels at is testing complex data
types. Most modern databases support complex types like `json` which
can be used to store unstructured data. Using `dbt-spec` we can build
a specification for these datatypes to ensure that they are well
formed.

```yaml
version: 2

models:
  - name: foo
    columns:
      - name: bar
        test:
          - spec.test:
              predicate: >-
                {{
                  spec.object_keys(
                    required=['baz'],
                    optional=['qux']
                  )
                }}
```

In this example we are testing the `bar` column on the model `foo` to
ensure that it contains the key `baz`. Optionally the datatype may
also contain the `qux` key. This table would pass the test:

| id  | bar                        | status |
|-----|----------------------------|--------|
| `0` | `{"baz": true}`            | pass   |
| `1` | `{"baz": false, "qux": 1}` | pass   |
| `2` | `{"baz": true, "quuz": 2}` | fail   |

The `key` predicate is open by default, this means that any extra keys
will *not* raise an error. In the previous example, the optional keys
are mostly there for documentation. If you would like to have a closed
object definition then use the `closed`.

```yaml
version: 2

models:
  - name: foo
    columns:
      - name: bar
        test:
          - spec.test:
              predicate: >-
                {{
                  spec.object_keys(
                    required=['baz'],
                    optional=['qux'],
                    closed=True
                  )
                }}
```

With this test, the row with `id` of `3` will fail the test.


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
