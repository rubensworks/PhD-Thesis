In this chapter, we tackle the second challenge of this PhD, which is:
"Indexing evolving data involves a *trade-off* between *storage size* and *lookup efficiency*".
As *evolving* knowledge graphs add a temporal dimension to regular knowledge graphs,
new storage and querying techniques are required.
A naive way to handle this temporal dimension would be to store each knowledge graph version as a separately materialized knowledge graph.
This can however introduce a tremendous storage overhead when consecutive versions are similar to each other.
Furthermore, querying over such a naive storage method would require going through _all_ of these versions,
which does not scale well when the number of versions is high.

The focus of our work in this chapter is to come up with a Web-friendly trade-off between storage size and lookup efficiency,
so that evolving knowledge graphs can be published on the Web without requiring high-end machines.
We introduce of a new indexing technique for evolving data,
that focuses on querying in a _stream-based_ manner.
This allows results to be sent to the client from the moment that they are found,
which reduces waiting time compared to batch-based querying.
Streaming results are especially useful when the number of results is very large,
and is memory friendly for machines with limited capabilities.

This chapter is based on the research question:
"How can we store RDF archives to enable efficient versioned triple pattern queries with offsets?"
We focus on triple pattern queries, as these are the fundamental building blocks
for more complex SPARQL queries over knowledge graphs.
We answer this research question by introducing a storage technique
that introduces various temporal indexes next to the typical indexes that are required for knowledge graphs.
These indexes are essential for achieving efficient querying for different kinds of versioned queries.
We extensively evaluate this approach based on our implementation _OSTRICH_.
Our results show that our method achieves a trade-off between storage size and lookup efficiency
that is useful for hosting evolving knowledge graphs on the Web.
Concretely, at the cost of an increase in storage size and ingestion time,
query execution time is significantly reduced.
As storage is typically cheap, and ingestion can happen offline, this trade-off is acceptable in a Web environment.
