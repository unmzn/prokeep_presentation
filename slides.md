---
theme: gaia
_class: lead
paginate: true
backgroundColor: #222
color: #eee
style: @import url('https://unpkg.com/tailwindcss@^2/dist/utilities.min.css');
---
# "GOOD MAGIC"
## Elixir, Macros and Ecto

<!--
Thank you for coming
I call this talk good magic, elixir macros and ecto
-->
---
# What am I calling "Bad Magic"?
- Language itself has special features that "you" can't use
   - Like typed collections in Go v1 before generics were added
   ```golang
      var menu map[string]float64
   ```
   - Inconsistent, confusing, and frustrating
      - Cognitive load of special cases
---
# Vs. Elixir Magic:
- Once understood, totally linear and predictable
- User-accessible
   - See the inner workings
   - Combine in any configuration you like
   - Call any macro from your own macros
      - (including `def`, `defmodule`, and `defmacro`)
<!--
-->
---
# Hot Takes
- Macros >> boilerplate
- Elixir is a Lisp, which is the best part about it
- Ecto is so good, it's _better_ than raw SQL
- 2 Design patterns (with Ecto examples):
   - "Additive Use"
   - "Composable Joins"
<!--
Focussing in on Ecto to demonstrate the power of Elixir in a way that should be familiar and well-motivated.

Going to look at Ecto.Query and Ecto.Migration

I definitely didn't invent "additive use" - Phoenix codegen uses it extensively. I haven't seen it named though so the name is mine.

Other people have blogged about composable joins, but I haven't seen anyone else talk about select_merge
-->
--- 
# Elixir is a Lisp
- `Macro.t()` == Elixir AST == quoted expression
- 3-tuple: `{:function_name, [metadata], function_arguments}`
- EVERY BIT of Elixir code is a tree of that AST once "expanded"
   - We can see the AST using `quote do ... end` or `quote do: \n`
      - ex: `quote do: sum(1,2,3)`
      - result: `{:sum, [], [1, 2, 3]}`
<!--
There is no official definition of "what a Lisp is", but:
- "Code is data"
   - The real AST is accessible to us
   - It can be manipulated and then executed
- Like Racket and Clojure, Elixir macros are "hygenic"
   - There is actually an escape hatch for unhygenic macros

Those familiar with CL / Scheme / Clojure may recognize the similarity
Unlike the paren-based lisps, Elixir has tuples as a "special form"
Also unlike those others, the AST is _slightly_ hidden under Ruby-like syntax
-->
---
# 3 things you can do with an AST:
1. get the textual representation with `Macro.to_string`
```elixir
iex> Macro.to_string({:sum, [], [1,2,3]}) -> "sum(1, 2, 3)"
```
2. Since it's always nested 3-tuples, you can store it any variable, map etc. or pass as parameter
3. Inside a macro or inside a quoted block
   - It can be "inserted" with `unquote`
   - Unquote doesn't work outside of quote block

---
# Processing order
Elixir source code →
Macro expansion →
AST → 
Typecheck + Compilation → 
Erlang bytecode →
Execution in the BEAM
<!--
Remember that def, defmodule and many more are themselves macros

Macro expansion is a tree
- calling macro expanded first, then recursive descent

Anything that happens at macro expansion time is LONG before compilation to bytecode, and thus even further from execution
-->
---
# Elixir Macros Migration example
- Sci-fi shipyard company
- Ships and employees are assigned to shipyards
- Work orders hava a many-many relationship with ships and employees
<!--
Example purpose:
- show composable joins pattern
- introduce the schema

SAY:
- Macro arguments are automatically quoted, must always be unquoted to be used
- Things I didn't know were possible, but work perfectly
- My-style table definitions and familiar-style coexist perfectly side-by-side
   - since we `use Ecto.Migration` in our own `__using__` definition, we have access to `timestamps()` and the other utilities we are used to
   - I think of this as the "additive using pattern"
- macro can be defined privately
- I don't think I'd break it down this far in production code

SHOW:
- init migration and migration macros file side-by-side
- macros defined inside macros, referencing sibling macro
- interactions between base_fields() and base_table()
   - it can define the unique constraint
- Can't use default arguments

SHOW:
- table definitions

SHOW:
- compilation order
-->

---
![bg left:100% 75%](./assets/diagram.svg)
<!--
Omitted fields:
- metadata
- timestamps

4 core tables
2 join tables

6 FK relationships
-->
---

## Ecto.Query DSL awesomeness
- Safe
   - Always parameterized
- Efficient
   - Ecto.Query will optimize before outputting SQL
- Flexible
   - Macros just generate `Ecto.Query` struct
   - `fragment/1` _safe_ escape hatch
   - Composable joins!

<!--
- Not easy to make SQL injection vulnerability
- Fragment will enforce at expansion time that all parameters are strings or atoms (NOT templates)
- Don't have a fragment example
   - Can be in where or select
-->

---
# Ecto.Query Composable Joins Pattern
## 3 requirements:
1. Each composable function has to take the query being built as a parameter, then pass it to the `from` macro.
2. In all the `from` bodies, when adding a table to the join alias it with `as: :alias` then always reference it with `as(:alias)`.
3. Either a single `select:` or a "base" `select:` and additional `select_merge:`
<!--
SHOW:
EctoCompose example
For each shipyard and each assigned employee, show the count of assigned work orders

query = EctoCompose.all_together("EARTH")
- query string representation
   -if you to_string or dbg an Ecto.query, it just gives you back an approximation of the source query
- 3 layers
-->
---
# Outcome:
- Each piece can be developed and debugged sequentially.
   - A limitation is that they must be pipelined in order
```elixir
iex(2)> Repo.to_sql(:all, query)
{
   'SELECT s0.name, e1.name, count(*) FROM shipyards AS s0
   INNER JOIN employees AS e1 ON e1.assigned_shipyard_id = s0.id 
   INNER JOIN work_order_assignments AS w2 ON e1.id = w2.assigned_employee_id 
   WHERE (s0.name ILIKE $1) 
   GROUP BY s0.name, e1.name,'

   ["%EARTH%"]
}
```

<!--
SAY:
- Note parameterized
- Note that composition doesn't "leak" by causing the resulting query to have subqueries or other mess
- The chosen alias also does not leak
- Named bindings and select / select_merge do introduce dependencies between the components, they have to be pipelined in order

Variations:
 - "L2"
 - "GEO"
-->

---
# Conclusion
- Elixir "code is data"
   - Macro system is cleverly designed
      - With `use` we can tie macros deeply into macro definition
   - "AST-ify" with `quote`, use / execute with `unquote`
- Ecto is super powerful
   - Can already represent whatever data or queries we want out of the box
   - We can extend it with our own macros at will to reduce boilerplate

<!-- 

>
