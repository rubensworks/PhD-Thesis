The challenge that is handled in this chapter is:
"Publishing *evolving* data via a *queryable interface* is costly."
While the previous chapter focused on querying heterogeneous sources on the Web containing *static* knowledge graphs,
this chapter focuses on *continuous* querying on the Web with *evolving* knowledge graphs.
Compared to [](#storing) —in which we introduced a storage technique for evolving knowledge graphs—,
this chapter focuses on the publishing interface on top of that.
This publishing interface is required for exposing evolving knowledge graphs on the Web.
As such, the interface introduced in this work could be implemented based on the storage backend from [](#storing).

A query interface that accepts continuous queries over evolving knowledge graphs,
inherently requires more server effort compared to one-time queries over static knowledge graphs.
That is because queries need to be evaluated *continuously* instead of only *once*.
As such, when evolving knowledge graphs need to be published on the Web,
an interface is needed that scales well in a public Web environment with a potentially large number of concurrent clients.

The work in this chapter is based on the research question:
"Can clients use volatility knowledge to perform more efficient continuous SPARQL query evaluation by polling for data?".
We answer this research question by introducing a query interface
that exposes evolving knowledge graphs annotated with their volatility.
Based on these volatility annotations, clients can detect for *how long* parts of the knowledge graph will remain valid,
and when new queries need to be initiated to calculate next up-to-date results.
We implemented our approach as a system called *TPF Query Streamer*.
Our evaluations show that the server load with this approach scales better
with an increasing number of concurrent clients
compared other solutions.
This shows that our technique is a good candidate for publishing evolving knowledge graphs on the Web.
