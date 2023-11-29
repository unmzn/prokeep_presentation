
# Intro
## Me

## Goals:
 - Macro.t() == Elixir AST == quoted expression
    - 3-tuple: `{:function_call, [metadata_kwlist], [args]}`
      - `{atom | tuple, list, list | atom}`
    - you can do 3 things with it:
       1. get the textual representation with `Macro.to_string` (only useful as a teaching tool AFAIK)
       2. Since it's literally just nested 3-tuples, you can store it any variable / map etc or pass as param
       3. In a macro and inside a quoted block
         - it can be pasted/interpolated anywhere
         - be unquoted inside a larger quoted expression
         - unquote doesn't work outside of quote block
   - Further reading:
      - Look into the module lifecycle and `__using__`
- Ecto.Query
- PG:
   - functions / operators
      - aggregates
      - json

# Thesis
- ecto.query awesome
   - claim:
      - can write arbitrary PG queries
      - that are idiomatic and composable Elixir
      - yet look hand-optimized
   - [ ] Example: composable queries
   - [ ] input AST -> Ecto.Query pipeline
   - [ ] introspection tools:
      - [ ] see expanded
      - [ ] see Query fields
      - [ ] see result SQL
- pg awesome
   - subthesis:
      - a single query can build whatever you can imagine
   - [-] Example: row_to_json metadata filtering cross table union
   - [ ] custom functions example?
- fragment makes them awesome together
   - why?
      - safe (you'll see)
      - integrated with rest of Ecto.Query
         - drop in in arbitrary places
         - variable interpolation (with a little work)
   - [ ] show a cool example
   - [ ] try and make generic
      - [ ] try literal (won't work)
   - [ ] show macro example



# Footnotes / credits
schema_spy

## Further reading:
Elixir syntax ref:
https://hexdocs.pm/elixir/syntax-reference.html#the-elixir-ast

AST great explain:
https://dorgan.netlify.app/posts/2021/04/the_elixir_ast/

Great graph examples:
https://aiven.io/blog/explore-the-new-search-and-cycle-features-in-postgresql-14


# Prokeep
"A love letter to Ecto / Postgres, with the help of the `fragment/1` macro"

Introduce example

Ecto good + example(s)
- show introspection
- show "composable join"
- show parameterized

Postgres good + example(s)
- graph features
   - subcomponents example
- notify example
   - trigger
   - send message on new ship

Fragment combines best of both
- JSON example
- aggregate example
- regex example?
- safety / error messages example
   - literal vs parameter

## PG 15
MERGE
regex

## PG 16


# 2023-11-29 Wed
## TODO:
[x] svg
[x] More seed data
[x] remove components
[x] re-generate schema diagram
   [x] get SchemaSpy working
