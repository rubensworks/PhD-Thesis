### Abstract
{:#querying-evolving_abstract .no-label-increment}

Existing solutions to query dynamic Linked Data sources extend the SPARQL language,
and require continuous server processing for each query.
Traditional SPARQL endpoints already accept highly expressive queries,
so extending these endpoints for time-sensitive queries increases the server cost even further.
To make continuous querying over dynamic Linked Data more affordable,
we extend the low-cost Triple Pattern Fragments (TPF)
interface with support for time-sensitive queries.
In this paper, we introduce the TPF Query Streamer that allows clients to evaluate SPARQL queries
with continuously updating results.
Our experiments indicate that this extension significantly lowers the server complexity,
at the expense of an increase in the execution time per query.
We prove that by moving the complexity of continuously evaluating queries over
dynamic Linked Data to the clients and thus increasing bandwidth usage,
the cost at the server side is significantly reduced.
Our results show that this solution makes real-time querying more scalable for a large amount
of concurrent clients when compared to the alternatives.
