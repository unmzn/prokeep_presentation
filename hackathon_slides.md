---
theme: gaia
_class: lead
paginate: true
backgroundColor: #222
color: #eee
style: @import url('https://unpkg.com/tailwindcss@^2/dist/utilities.min.css');
---

# Hackathon 2024 Postgres
## A GraphQL Performance Adventure

<!--
I wanted to optimize from within the app because of past experiences

Steven and Paul naturally gravitated to Ops
-->
---
# TOC:
- RDS / slow queries
- Honeycomb
- Dead End
- Gold Mine

---
# RDS / slow queries
From the rds metrics, the top 5 offenders are:
- `list_closed_threads`
- `autovacuum oban_jobs`
- `my_inbox_threads`
- `groups_query`
- `my_open_threads`

<!--
SHOW RDS METRICS


- pulled unique queries from the log
- cross-referenced with the RDS metrics
- 
# First takeaway: db isn't struggling at current levels
# Second takeaway: Our DB load is dominated by CPU according to the "wait" metric

But I didn't know how to identify the threads queries at this point in the story

I learned later that these have already been targeted

I think it was too zoomed in

Hard to know what to do with this information
-->

---
# Honeycomb
## questions:
- rest vs gql?
- total cumulative latency?
- total number of requests?

<!--
SHOW HONEYCOMB (2 tabs)

- GQL dwarfs rest
- thread functions dominate
- thread functions dominate as well

## Initial thoughts:
myOpenThreadsQuery and myInboxThreadsQuery are the natural target.
Their counts differ by <2%
-->

---
# Looking at the OTEL trace

- authn
- authz
- teltale N + 1

<!--
SHOW TRACES
-->

---
# N+1 investigation

<!--
SHOW DISTRIBUTOR (thread types schema file)

Already using dataloader lower down
Main impediment seems to be pagination and the order things are wrapped
- Also the fact that we're not building an Ecto.Query
Dataloader needs the query
-->

---
# Dead end
---
### Existing query
```sql
WITH cursor AS ( SELECT updated_at AS key FROM threads WHERE id = $3)
SELECT DISTINCT ON (updated_at) *
FROM (
(SELECT
    *
  FROM
    threads
  JOIN
    inbox_threads_for_users
      ON inbox_threads_for_users.user_id = $1
        AND inbox_threads_for_users.thread_id = threads.id
  WHERE
    ((SELECT key FROM cursor) IS NULL OR threads.updated_at < (SELECT key FROM cursor))
    AND NOT EXISTS (SELECT * FROM open_threads_for_users WHERE open_threads_for_users.thread_id = threads.id AND open_threads_for_users.user_id = $1)
  ORDER BY
    threads.updated_at DESC
  LIMIT
    $4
) UNION (
  SELECT
    *
  FROM
    threads
  JOIN
    inbox_threads_for_groups
      ON inbox_threads_for_groups.group_id = ANY($2)
        AND inbox_threads_for_groups.thread_id = threads.id
  WHERE
    ((SELECT key FROM cursor) IS NULL OR updated_at < (SELECT key FROM cursor))
    AND NOT EXISTS (SELECT * FROM open_threads_for_users WHERE open_threads_for_users.thread_id = threads.id AND open_threads_for_users.user_id = $1)
  ORDER BY
    updated_at DESC
  LIMIT
    $4
)) page
ORDER BY updated_at DESC LIMIT $4;
```
<!--
S/o Wes, circa Jan 2022
Dwight / Mark too?
-->

---
# attempted to rewrite query
```elixir
from t in Thread,
  distinct: t.updated_at,
  where: ^cursor_condition,
  left_join: itfu in assoc(t, :inbox_threads_for_users),
  on: itfu.user_id == ^user_id,
  left_join: otfu in assoc(t, :open_threads_for_users),
  on: otfu.user_id == ^user_id,
  left_join: itfg in assoc(t, :inbox_threads_for_groups),
  on: itfg.group_id in ^group_ids,
  where: is_nil(otfu.thread_id),
  where: not is_nil(itfu.thread_id) or not is_nil(itfg.thread_id),
  order_by: [desc: t.updated_at],
  limit: ^limit
```

<!--
It WAS a drop-in replacement
Unfortunately it was ~8x slower
- The query plan leads to a giant result set being constructed and sorted
- OPTIONAL: show query plan
- Moving the filter condition "up" to the joins didn't help
   - BECAUSE IT'S A LEFT JOIN
- Writing up this writeup made me realize the issue
- Moving up the where condition took it from ~600ms to ~400ms
- Lesson:
   - Put WHERE as high in the query as possible, ESPECIALLY before joins
- still worse
-->

---
# Perf vs pretty
Sometimes hand-optimized SQL still wins

<!--
- old query
   - the query is already quite optimized
   - it's structurally difficult to translate to Ecto syntax
- general lessons:
   - EXISTS is faster than JOIN if applicable
   - Limit and sort as early as possible
   - CTEs are awkward in Ecto
      - It might be possible to do a subquery
   - Sometimes hand-optimzied SQL still wins
-->

---
# Gold mine

<!--
# I'm only reporting on `myInboxThreadsQuery` BUT
- Applies to EVERY GQL thread query in the app (AFAICT) (approx. 40 usages in client-lib)
-->
---
## Wins:
Bytes-on-the-wire 30-80%
Latency 30-80%
Spans 30-80%

<!---
SHOW JAGER
(optional) SHOW BRUNO 

   - How?
      - I'm as surprised as you
      - I left the fields in that broke the app when removed, this is what was left
      - Try it for yourself! (deployed in QA)
      - Evidence of the anti-patern nature of the way we use named fragments
         - FE doesn't navigate 6 layers deep to access data
         - Finished query has 1 leaf at layer 3 and 1 at layer 4
--->
---
# How?
- Show diff
- Show expanded diff

<!--
SHOW DIFF 1
SHOW DIFF 2

Started attacking the problem from the other end
I thought I might be able to prune off some layers of the query tree
I succeeded beyond my wildest dreams
BEHOLD
Just start ripping things out and see what breaks
Becomes more and more reasonable as complexity increases
QA is ESSSENTIAL

## Existing query:
Up to 6! layers of nesting
When fully expanded, effective query is over 1000 lines

### expanded version:
- generates byte-for-byte identical output
-->

---
# Final takeaways
- Otel is good at it's job
- Cycle time is ESSENTIAL
- If we can do less work, it has compounding benefits

<!--
READ THESE NOTES
NOTICE THE NESTING

- Otel is good at it's job
   - ESPECIALLY for getting the "bigger picture"
   - Span count is a pretty good proxy for latency, but with high stability between runs
      - Similar to "wall clock vs instruction count"
   - Discover in honeycomb, reproduce in Jager worked GREAT
      - Spans looked identical, giving high confidence
      - Jager + local enabled quick cycling
- Cycle time is ESSENTIAL
   - I did hundreds of iterations
   - If I had to wait for CI for every change this would have gone nowhere
   - IF the FE doesn't YSOD, it's fully working 99% of the time
- If we can do less work, it has compounding benefits
   - Often have to traverse the stack to achieve, as in this case
   - Ultimately simplest possible optimization, but NOT the first one I thought of
      - I think we generally assume the FE needs everything it is asking for
      - I found quite the opposite in this case
-->
---
### Evolved Process:
- Find root fragment
- Copy to new file (optional)
- Flatten all named fragments to fields or inline fragments
- Cycle:
   - Comment out 1 or more fields
   - Save file
   - Wait for page refresh
   - 5-10s quick QA
   - If working, remove comment
<!--
-->
---

