### Related Work
{:#querying-evolving_related-work}

In this section, we first explain techniques to perform RDF annotation,
which will be used to determine freshness.
Then, we zoom in on possible representations of temporal data in&nbsp;RDF.
We finish by discussing existing SPARQL streaming extensions
and a low-cost (static) Linked Data publication technique.

#### RDF Annotations
{:#querying-evolving_related-work_annotations}

Annotations allow us to attach metadata to triples.
We might for example want to say that a triple is
only valid within a certain time interval, or that a triple is only valid in a certain geographical area.

[RDF 1.0](cite:cites spec:rdf-old) allows triple annotation through *reification*.
This mechanism uses *subject*, *predicate*, and *object* as predicates, which allow the addition of annotations
to such reified RDF triples.
The downside of this approach is that one triple is now transformed to three triples, which significantly increases the
total amount of triples.

[Singleton Properties](cite:cites singletonproperties) create unique instances (singletons) of predicates, which then can be used for further specifying
that relationship, for example, by adding annotations. New instances of predicates are created by relating them to the
old predicate through the `sp:singletonPropertyOf` predicate.
While this approach requires fewer triples than reification to represent the same information, it still has
the issue of the original triple being lost, because the predicate is changed in this approach.

With [RDF 1.1](cite:cites spec:rdf) came *graph* support, which allows triples to be encapsulated into named graphs, which can also be annotated.
Graph-based annotation requires fewer triples than both reification and singleton properties when representing
the same information. It requires the addition of a fourth element to the triple which transforms it to a quad.
This fourth element, the *graph*, can be used to add the annotations to.

#### Temporal data in the RDF model

Regular RDF triples cannot express the time and space in which the fact they describe is true.
In domains where data needs to be represented for certain times or time ranges, these traditional representations
should thus be extended.
There are [two main mechanisms for adding time](cite:cites temporalrdf).
*Versioning* will take snapshots of the complete graph every time a change occurs.
*Time labeling* will annotate triples with their change time.
The latter is believed to be a better approach in the context of RDF,
because complete snapshots introduce overhead,
especially if only a small part of the graph changes.
Gutierrez et al. made a distinction between *point-based* and *interval-based* labeling,
[which are interchangeable](cite:cites timerdf).
The former states information about an element at a certain time instant, while the latter states
information at all possible times between two time instants.

The same authors introduced a&nbsp;[temporal vocabulary](cite:cites timerdf) for the discussed mechanisms, which will
be referred to as `tmp` in the remainder of this chapter. Its core predicates&nbsp;are:

* `tmp:interval`: This predicate can be used on a subject to make it valid in a certain time interval.
    The range of this property is a time interval, which is represented by the two mandatory
    properties `tmp:initial` and `tmp:final`.
* `tmp:instant`: Used on subjects to make it valid on a certain time instant as a point-based time representation.
    The range of this property is `xsd:dateTime`.
* `tmp:initial` and `tmp:final`: The domain of these predicates is a time interval.
    Their range is a `xsd:dateTime`, and they respectively indicate the start and the
    end of the interval-based time representation.

Next to these properties, we will also introduce our own predicate `tmp:expiration` with range `xsd:dateTime`
which indicates that the subject is only valid up until the given time.

#### SPARQL Streaming Extensions

Several SPARQL extensions exist that enable querying over data streams.
These data streams are traditionaly represented as a monotonically non-decreasing stream of triples that are annotated with their timestamp.
These require [*continuous processing*](cite:cites streamreasoning) of queries because of the constantly changing data.

[C-SPARQL](cite:cites csparql) is an approach to querying over static and dynamic data.
This system requires the client to *register* a query to the server in an extended
SPARQL syntax that allows the use of *windows* over dynamic data.
This [*query registration*](cite:cites streamreasoning,streamreasoningsofar)
must occur by clients to make sure that the streaming-enabled SPARQL endpoint can continuously re-evaluate this query,
as opposed to traditional endpoints where the query is evaluated only once.
A&nbsp;[*window*](cite:cites arasu2004stream) is a subsection of facts ordered by time so that not all available
information has to be taken into account while processing. These windows can have a certain size which
indicates the time range and is advanced in time by a&nbsp;*stepsize*.
C-SPARQL's execution of queries is based on the combination of a regular SPARQL engine with a
[*Data Stream Management System* (DSMS)](cite:cites arasu2004stream). The internal model of C-SPARQL 
creates queries that distribute work between the DSMS and the SPARQL engine to respectively
process the dynamic and static data.

[*CQELS*](cite:cites cqels) is a *white box* approach, as opposed to *black box*
approaches like C-SPARQL.
This means that CQELS natively implements all query operators without transforming it to another
language, removing the overhead of delegating it to another system.
The syntax is similar to that of C-SPARQL, also supporting query registration and time windows.
According to previous research CQELS, CQELS performs much better than C-SPARQL for large
datasets; for simple queries and small datasets the opposite is true.

#### Triple Pattern Fragments
    
Experiments have shown that [more than half of public SPARQL endpoints have an availability of less than 95%](cite:cites buil2013sparql).
Any number of clients can send arbitrarily complex SPARQL queries, which could form a bottleneck in endpoints.
[*Triple Pattern Fragments* (TPF)](cite:cites ldf) aim to solve this issue of high interface cost by moving part of
the query evaluation to the client, which reduces the server load, at the cost of increased query times and bandwidth.
The purposely limited interface only accepts separate triple pattern queries.
Clients can use it to evaluate more complex SPARQL queries locally,
also over federations of interfaces.
