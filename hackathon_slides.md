---
theme: gaia
_class: lead
paginate: true
backgroundColor: #222
color: #eee
style: @import url('https://unpkg.com/tailwindcss@^2/dist/utilities.min.css');
---
# HACKATHON

### My subproject: honecomb guided latency eating
Initial thoughts:
myOpenThreadsQuery and myInboxThreadsQuery are the natural target.
Their counts differ by <2%


---
# story
---

## RDS / slow queries
pulled unique queries from the log
cross-referenced with the RDS metrics
First takeaway: db isn't struggling at current levels
Second takeaway: Our DB load is dominated by CPU according to the "wait" metric

---
From the rds metrics, the top 5 offenders are:
- `list_closed_threads`
- `autovacuum oban_jobs`
- `my_inbox_threads`
- `groups_query`
- `my_open_threads`

But I didn't know how to identify the threads queries at this point in the story

---

# Honeycomb
## questions:
- rest vs gql?
   - GQL dwarfs rest
- total cumulative latency?
   - thread functions dominate
- total number of requests?
   - thread functions dominate as well

---
# Looking at the OTEL trace
- authn
- authz
- teltale N + 1

---
# N+1 investigation
Already using dataloader lower down
Main impediment seems to be pagination and the order things are wrapped
- Also the fact that we're not building an Ecto.Query
Dataloader needs the query

---
# attempted to optimize query
It WAS a drop-in replacement
Unfortunately it was ~10x slower
- The query plan leads to a giant result set being constructed and sorted
- Moving the filter condition "up" to the joins didn't help
   - BECAUSE IT'S A LEFT JOIN
- Writing up this writeup made me realize the issue
- Moving up the where condition took it from ~600ms to ~400ms
- Lesson:
   - Put WHERE as high in the query as possible, ESPECIALLY before joins
- still worse

---
# takaways
the query is already quite optimized
it's structurally difficult to translate to Ecto syntax

---
# One dead end and one gold mine: an optimization adventure
---
# Chapter 2: 
## The Gold Mine, or "Redemption"
---

Started attacking the problem from the other end
I thought I might be able to prune off some layers of the query tree
I succeeded beyond my wildest dreams
BEHOLD

---
#### currently no distributor code
makes it really easy to do side by side comparisions


---
# Beginnings

---
# Dead end
## The optimized query
S/o Wes, circa Jan 2022

---
Perf vs pretty

## My final version:
## Takeaways:
- EXISTS is faster than JOIN if applicable
- Limit and sort as early as possible
- CTEs are awkward in Ecto
   - It might be possible to do a subquery
- Sometimes hand-optimzied SQL still wins

---
# Gold mine
Just start ripping things out and see what breaks
Becomes more and more reasonable as complexity increases
QA is ESSSENTIAL

<!--
## Existing query:
Up to 6! layers of nesting
When fully expanded, effective query is over 1000 lines

### expanded version:
- generates byte-for-byte identical output
-->
---

# Specifically:
Bytes-on-the-wire 30-80%
Latency 30-80%
Spans 30-80%

---
# wins:
## Overall
Cloud data ingress / egress (est. 10-50%)
Span count (est. 10-50%)

---
# I'm only reporting on `myInboxThreadsQuery` BUT
- Applies to EVERY GQL thread query in the app (AFAICT) (approx. 40 usages in client-lib)
   - How?
      - I'm as surprised as you
      - I left the fields in that broke the app when removed, this is what was left
      - Try it for yourself! (deployed in QA)
      - Evidence of the anti-patern nature of the way we use named fragments
         - FE doesn't navigate 6 layers deep to access data
         - Finished query has 1 leaf at layer 3 and 1 at layer 4
---

# Evolved Process:
- Identify hot query
- Find root fragment
- Copy to new file (optional)
- Flatten all named fragments to fields or inline fragments
- Cycle:
   - Comment out 1 or more fields
   - Save file
   - Wait for page refresh
   - 5-10s quick QA
   - If working, remove comment
   - Rinse, repeat
---

# Final takeaways
- Otel is good at it's job
   - ESPECIALLY for getting the "bigger picture"
   - Span count is a pretty good proxy for latency, but with high stability between runs
      - Similar to "wall clock vs instruction count"
   - Discover in honeycomb, reproduce in Jager worked GREAT
      - Spans looked identical, giving high confidence
      - Jager + local enabled quick cycling
- Slow query optimization did work (s/o Mark + Dwight?)
   - Remaining 3 thread queries still need to be optimized
   - If possible, the "groups query" should be the next target
- Cycle time is ESSENTIAL
   - I did hundreds of iterations
   - If I had to wait for CI for every change this would have gone nowhere
   - IF the FE doesn't YSOD, it's fully working 99% of the time
- If we can do less work, it has compounding benefits
   - Often have to traverse the stack to achieve, as in this case
   - Ultimately simplest possible optimization, but NOT the first one I thought of
      - I think we generally assume the FE needs everything it is asking for
      - I found quite the opposite in this case
---
