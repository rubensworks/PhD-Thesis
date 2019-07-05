### Related Work
{:#storing_related-work}

In this section, we discuss existing solutions and techniques for indexing and compression in RDF storage, without archiving support.
Then, we compare different RDF archiving solutions.
Finally, we discuss suitable benchmarks and different query types for RDF archives.
This section does not contain an exhaustive list of all relevant solutions and techniques,
instead, only those that are most relevant to this work are mentioned.

#### General RDF Indexing and Compression

RDF storage systems typically use indexing and compression techniques
for reducing query times and storage space.
These systems can either be based on existing database technologies,
such as [relational databases](cite:cites virtuoso) or [document stores](cite:cites dsparq),
or on techniques tailored to RDF.
These technologies can even be combined, such as approaches that detect [_emergent schemas_](cite:cites derivingemergentschemas,emergentschemas)
in RDF datasets, which allow parts of the data to be stored in relational databases
in order to increase compression and improve the efficiency of query evaluation.
These emergent schemas are recently being exploited as _characteristics sets_
in [native RDF approaches](cite:cites axondb,odyssey).
For the remainder of this article, we focus the RDF-specific techniques that have direct relevance to our approach.

[RDF-3X](cite:cites rdf3x) is an RDF storage technique that is based
on a clustered B+Tree with 18 indexes in which triples are sorted lexicographically.
Given that a triple consists of
a subject (S), predicate (P) and object (O),
it includes six indexes for different triple component orders (SPO, SOP, OSP, OPS, PSO and POS),
six aggregated indexes (SP, SO, PS, PO, OS, and OP),
and three one-valued indexes (S, P, and O).
A dictionary is used to compress common triple components.
When evaluating SPARQL queries, optimal indexes can be selected based on the query's triple patterns.
Furthermore, the store allows update operations.
In our storage approach, we will reuse the concept of multiple indexes
and encoding triple components in a dictionary.

[Hexastore](cite:cites hexastore) is a similar approach as it uses six different sorted lists,
one for each possible triple component order.
Also, it uses dictionary encoding to compress common triple components.
An alternative is [Triplebit](cite:cites triplebit), which is based on a two-dimensional storage matrix.
Columns correspond to predicates, and rows to subjects and objects.
This sparse matrix is compressed and dictionary-encoded to reduce storage requirements.
Furthermore, it uses auxiliary index structures to improve index selection during query evaluation.

[K2-Triples](cite:cites k2triples) is another RDF storage technique that uses _k2-tree_
structures to the data, which results in high compression rates.
These structures allow SPARQL queries to be evaluated in memory without decompressing the structures.

[RDFCSA](cite:cites rdfcsa) is a compact RDF storage technique.
It is a _self-index_ that stores the data together with its index, which results in less storage space than raw storage.
Furthermore, it is built on the concept of _compressed suffix arrays_,
which compresses text while still allowing efficient pattern-based search on it.
RDFCSA requires about twice the storage space compared to K2-Triples, but it is faster for most queries.

[HDT](cite:cites hdt) is a binary RDF representation that is highly compressed
and provides indexing structures that enable efficient querying.
It consists of three main components:

Header
: metadata describing the dataset

Dictionary
: mapping between triple components and unique IDs for reducing storage requirements of triples

Storage
: actual triples based on the IDs of the triple components

The dictionary component encodes triple components in four subsets.
The first subset consists of triple components that exist both as subject and objects.
The second and third subset respectively consists of the non-common subject and object component.
The last subset consists of the predicate components.
The storage part encodes triple components using the dictionary,
compacts the triples in a sorted predicate and object adjacency list,
and stores these adjacency list in a bitmap structure that efficiently
indicates the borders of these consecutive adjacency list.
By default, HDT only stores triples in the SPO-order.
When querying is required, enhanced triple indexes are constructed
to allow any triple pattern to be resolved efficiently based on the [HDT-FoQ](cite:cites hdtfoq) approach.
HDT archives are read-only, which leads to high efficiency and compressibility,
but makes them unsuitable for cases where datasets change frequently.
Its fast triple pattern queries and high compression rate make it
an appropriate backend storage method for [TPF](cite:cites ldf) servers.
Approaches like [LOD Laundromat](cite:cites lodlaundromat) combine HDT and TPF for hosting and publishing
650K+ Linked Datasets containing 38B+ triples, proving its usefulness at large scale.
Because of these reasons, we will reuse HDT snapshots as part of our storage solution.

#### RDF Archiving
{:#storing_related-work-archiving}

Linked Open Datasets typically [change over time](cite:cites datasetdynamics),
creating a need for [maintaining the history of the datasets](cite:cites archiving).
Hence, RDF archiving has been an active area of research over the last couple of years.
In the domain of non-RDF graph databases, several graph database extensions exist.
These extensions are either [wrapper-based](cite:cites fluxgraph,neo4jversioning), which leads to sub-optimal querying due to the lack of indexing,
or they are based on [changing the graph model](cite:cites neo4jtimedependentgraphs,neo4jmultilevelindex), which complicates the writing of queries.
Furthermore, none of the existing non-RDF graph stores offer native versioning capabilities at the time of writing.
We therefore only discuss RDF archiving for the remainder of this section.

Fernández et al. formally define an [_RDF archive_](cite:cites bear) as follows:
_An RDF archive graph A is a set of version-annotated triples._
Where a _version-annotated triple_ _(s, p, o):\[i\]_ is defined as _an RDF triple (s, p, o) with a label i ∈ N representing the version in which this triple holds._
The set of all [RDF triples](cite:cites spec:rdf) is defined as _(U ∪ B) × U × (U ∪ B ∪ L)_,
where _U_, _B_, and _L_, respectively represent the disjoint, infinite sets of URIs, blank nodes, and literals.
Furthermore,
_an RDF version of an RDF archive A at snapshot i is the RDF graph A(i) = {(s, p, o)|(s, p, o):\[i\] ∈ A}._
For the remainder of this article, we use the notation _V<sub>i</sub>_ to refer to the RDF version _A(i)_.

The [DIACHRON data model](cite:cites diachronql) introduces the concept of _diachronic datasets_,
i.e., datasets that contain diachronic entities, which are semantic entities that evolve over time.
This data model formally defines a diachronic dataset as a set of dataset versions together with metadata annotations about this dataset.
Each dataset version is defined as a set of records (i.e., tuples or triples), an associated schema,
temporal information about this version and metadata specific to this version.
Domain data must be reified in order to store it in the DIACHRON model.
Due to the simplicity of RDF archive model compared to the domain-specific DIACHRON data model,
we will use the model of Fernández et al. for the remainder of this document.

Systems for archiving Linked Open Data are categorized 
into [three non-orthogonal storage strategies](cite:cites archiving):

- The **Independent Copies (IC)** approach creates separate instantiations of datasets for
each change or set of changes.
- The **Change-Based (CB)** approach instead only stores change sets between versions.
- The **Timestamp-Based (TB)** approach stores the temporal validity of facts.

In the following sections, we discuss several existing RDF archiving systems, which use either pure IC, CB or TB, or hybrid IC/CB.
[](#storing_rdf-archive-systems) shows an overview of the discussed systems.

<figure id="storing_rdf-archive-systems" class="table" markdown="1">

| Name                                        | IC | CB | TB |
| ------------------------------------------- |----|----|----|
| [SemVersion](cite:cites semversion)         | ✓  |    |    |
| [Cassidy et. al.](cite:cites vcrdf)         |    | ✓  |    |
| [R&WBase](cite:cites rwbase)                |    | ✓  |    |
| [R43ples](cite:cites r43ples)               |    | ✓  |    |
| [Hauptman et. al.](cite:cites vcld)         |    |    | ✓  |
| [X-RDF-3X](cite:cites xrdf3x)               |    |    | ✓  |
| [RDF-TX](cite:cites rdftx)                  |    |    | ✓  |
| [v-RDFCSA](cite:cites selfindexingarchives) |    |    | ✓  |
| [Dydra](cite:cites dydra)                   |    |    | ✓  |
| [TailR](cite:cites tailr)                   | ✓  | ✓  |    |

<figcaption markdown="block">
Overview of RDF archiving solutions with their corresponding storage strategy:
Individual copies (IC), Change-based (CB), or Timestamp-based (TB).
</figcaption>
</figure>

##### Independent copies approaches
[SemVersion](cite:cites semversion) was one of the first works to look into tracking different versions of RDF graphs.
SemVersion is based on Concurrent Versions System (CVS) concepts to maintain different versions of ontologies,
such as diff, branching and merging.
Their approach consists of a separation of language-specific features with ontology versioning from general features together with RDF versioning.
Unfortunately, the implementation details on triple storage and retrieval are unknown.

##### Change-based approaches
Based on the Theory of Patches from the [Darcs software management system](cite:cites darcs),
[Cassidy et. al.](cite:cites vcrdf) propose to store changes to graphs as a series of patches, which makes it a CB approach.
They describe operations on versioned graphs such as reverse, revert and merge.
An implementation of their approach is provided using the Redland python library and MySQL
by representing each patch as named graphs and serializing them in [TriG](cito:citesAsAuthority TriG).
Furthermore, a preliminary evaluation shows that their implementation is significantly slower
than a native RDF store. They suggest a native implementation of the approach to avoid some of the overhead.

[Im et. al.](cite:cites vmrdf) propose a CB patching system based on a relational database.
In their approach, they use a storage scheme called *aggregated deltas*
which associates the latest version with each of the previous ones.
While aggregated deltas result in fast delta queries, they introduce much storage overhead.

[R&WBase](cite:cites rwbase) is a CB versioning system that adds an additional versioning layer to existing quad-stores.
It adds the functionality of tagging, branching and merging for datasets.
The graph element is used to represent the additions and deletions of patches,
which are respectively the even and uneven graph IDs.
Queries are resolved by looking at the highest even graph number of triples.

Graube et. al. introduce [R43ples](cite:cites r43ples) which stores change sets as separate named graphs, making it a CB system.
It supports the same versioning features as R&WBase and introduces new SPARQL keywords for these, such as REVISION, BRANCH and TAG.
As reconstructing a version requires combining all change sets that came before,
queries at a certain version are only usable for medium-sized datasets.

##### Timestamp-based approaches
[Hauptman et. al. introduce a similar delta-based storage approach](cite:cites vcld)
by storing each triple in a different named graph as a TB storage approach.
The identifying graph of each triple is used in a commit graph for SPARQL query evaluation at a certain version.
Their implementation is based on [Sesame](cite:cites sesame) and [Blazegraph](cite:cites blazegraph) and is slower than snapshot-based approaches, but uses less disk space.

[X-RDF-3X](cite:cites xrdf3x) is an extension of [RDF-3X](cite:cites rdf3x) which adds versioning support using the TB approach.
On storage-level, each triple is annotated with a creation and deletion timestamp.
This enables time-travel queries where only triples valid at the given time are returned.

[RDF-TX](cite:cites rdftx) is an in-memory query engine that supports a temporal SPARQL querying extension.
The system is based on compressed multi-version B+Trees that outperforms similar systems such as X-RDF-3X in terms of querying efficiency.
The required storage space after indexing is similar to that of X-RDF-3X.

[v-RDFCSA](cite:cites selfindexingarchives) is a self-indexing RDF archive mechanism,
based on the RDF self-index [RDFCSA](cite:cites rdfcsa),
that enables versioning queries on top of compressed RDF archives as a TB approach.
They evaluate their approach using the [BEAR](cite:cites bear) benchmark
and show that they can reduce storage space requirements 60 times compared to raw storage.
Furthermore, they reduce query evaluation times more than an order of magnitude compared to state of the art solutions.

[Dydra](cite:cites dydra) is an RDF graph storage platform with dataset versioning support.
They introduce the REVISION keyword, which is similar to the GRAPH SPARQL keyword for referring to different dataset versions.
Their implementation is based on B+Trees that are indexed in six ways  GSPO, GPOS, GOSP, SPOG, POSG, OSPG.
Each B+Tree value indicates the revisions in which a particular quad exists, which makes it a TB approach.

##### Hybrid approaches
[TailR](cite:cites tailr) is an HTTP archive for Linked Data pages based
on the [Memento protocol](cite:cites memento) for retrieving prior versions of certain HTTP resources.
It is a hybrid CB/IC approach as it starts by storing a dataset snapshot,
after which only deltas are stored for each consecutive version, as shown in [](#storing_regular-delta-chain).
When the chain becomes too long, or other conditions are fulfilled,
a new snapshot is created for the next version to avoid long version reconstruction times.

Results show that this is an effective way of [reducing version reconstruction times](cite:cites tailr),
in particular for many versions.
Within the delta chain, however, an increase in version reconstruction times can still be observed.
Furthermore, it requires more storage space than pure delta-based approaches.

The authors' implementation is based on a relational database system.
Evaluation shows that resource lookup times for any version ranges between
1 and 50 ms for 10 versions containing around 500K triples.
In total, these versions require ~64MB of storage space.

<figure id="storing_regular-delta-chain">
<img src="storing/img/regular-delta-chain.svg" alt="[regular delta chain]">
<figcaption markdown="block">
Delta chain in which deltas are relative to the previous delta, as is done in [TailR](cite:cites tailr).
</figcaption>
</figure>

#### RDF Archiving Benchmarks
{:#related-work-benchmarks}

[BEAR](cite:cites bear) is a benchmark for RDF archive systems.
The BEAR benchmark is based on three real-world datasets from different domains:

BEAR-A
: 58 weekly snapshots from the [Dynamic Linked Data Observatory](cite:cites datasetdynamics). This is the main dataset from the article on [BEAR](cite:cites bear).

BEAR-B
: The 100 most volatile resources from [DBpedia Live](cite:cites dbpedialive) over the course of three months
as three different granularities: instant, hour and day.

BEAR-C
: Dataset descriptions from the [Open Data Portal Watch](cite:cites opendataportalwatch) project over the course of 32 weeks.

The 58 versions of BEAR-A contain between 30M and 66M triples per version, with an average change ratio of 31%.
BEAR-A provides triple pattern queries for three different versioned query types for both result sets with a low and a high cardinality.
The queries are selected in such a way that they will be evaluated over triples of a certain dynamicity,
which requires the benchmarked systems to handle this dynamicity well.
BEAR-B provides a small collection of triple pattern queries corresponding to the real-world usage of DBpedia.
Finally, BEAR-C provides 10 complex SPARQL queries that were created with the help of Open Data experts.

BEAR provides baseline RDF archive implementations based on [HDT](cite:cites hdt) and
[Jena's](cite:cites jena) [TDB store](https://jena.apache.org/documentation/tdb/)
for the IC, CB, and TB approaches, but also hybrid IC/CB and TB/CB approaches.
The hybrid approaches are based on snapshots followed by delta chains, as implemented by [TailR](cite:cites tailr).
Due to HDT not supporting quads, the TB and TB/CB approaches could not be implemented in the HDT baseline implementations.

Results show that IC for both Jena and HDT requires more storage space than the compressed deltas for the three datasets.
CB results in less storage space for both approaches for BEAR-A and BEAR-B, but not for BEAR-C because that dataset is so dynamic that
the deltas require more storage space than they would in with IC.
Jena-TB results in the least storage space of Jena-based approaches,
however,
it fails for BEAR-B-instant because of the large amount of versions
as Jena is less efficient for many graphs.

The hybrid approaches are evaluated with different delta chain lengths and expectedly show
that shorter delta chains lead to results similar to IC, and longer delta chains lead are similar to CB or TB.
The queries for BEAR-A and BEAR-B show that
IC results in constant evaluation times for any version,
CB times increase for each following version,
and TB also result in constant times.
The HDT-based approaches outperform Jena in all cases because of its compressed nature.
The IC/CB hybrid approaches similarly show increasing evaluation times for each version,
with a drop each time a new snapshot is created.
The IC/TB hybrid Jena approach has slowly increasing evaluation times for each version,
but they are significantly lower than the regular TB approach.

The queries of BEAR-C currently can not be solved by the archiving strategies in a straightforward way,
but they are designed to help foster the development of future RDF archiving solutions.
While queries of BEAR-A and BEAR-B are just triple pattern queries and therefore do not cover the full SPARQL spectrum,
they provide the basis for more complex queries, as is proven by the [TPF framework](cite:cites ldf),
which makes them sufficient for benchmarking.

[EvoGen](cite:cites evogen) is an RDF archive systems benchmark that is based on the synthetic [LUBM dataset generator](cite:cites lubm).
It is an extension of the LUBM generator with additional classes and properties for introducing dataset evolution on schema-level.
EvoGen enables the user to tweak parameters of the dataset and query generation process,
for example to change the dataset dynamicity and the number of versions.

While EvoGen offers more flexibility than BEAR in terms of configurability.
BEAR provides real-world datasets and baseline implementations which lowers the barrier towards its usage.
Hence, we will use the BEAR dataset in this work for benchmarking our system.

#### Query atoms

The query atoms that will be introduced in this section are based on
the [RDF data model](cite:cites spec:rdf) and [SPARQL query language](cite:cites spec:sparqllang).
In these models, a _triple pattern_ is defined as _(U ∪ V) × (U ∪ V) × (U ∪ L ∪ V)_, with _V_ being the infinite set of variables.
A set of triple patterns is called a _Basic Graph Pattern_, which forms the basis of a SPARQL query.
The evaluation of a SPARQL query _Q_ on an RDF graph _G_ containing RDF triples,
produces a bag of solution mappings _\[\[Q\]\]<sub>G</sub>_.

To cover the retrieval demands in RDF archiving,
[five foundational query types were introduced](cite:cites bear),
which are referred to as _query atoms_:

1. **Version materialization (VM)** retrieves data using a query _Q_ targeted at a single version _V<sub>i</sub>_.
Formally: _VM(Q, V<sub>i</sub>) = \[\[Q\]\]<sub>V<sub>i</sub></sub>_.
Example: _Which books were present in the library yesterday?_
2. **Delta materialization (DM)** retrieves query _Q_'s result change sets between two versions _V<sub>i</sub>_ and _V<sub>j</sub>_.
Formally: _DM(Q, V<sub>i</sub>, V<sub>j</sub>)=(Ω<sup>+</sup>, Ω<sup>−</sup>). With Ω<sup>+</sup> = \[\[Q\]\]<sub>V<sub>i</sub></sub> \ \[\[Q\]\]<sub>V<sub>j</sub></sub> and Ω<sup>−</sup> = \[\[Q\]\]<sub>V<sub>j</sub></sub> \ \[\[Q\]\]<sub>V<sub>i</sub></sub>_.
Example: _Which books were returned or taken from the library between yesterday and now?_
3. **Version query (VQ)** annotates query _Q_'s results with the versions (of RDF archive A) in which they are valid.
Formally: _VQ(Q, A) = {(Ω, W) | W = {A(i) | Ω=\[\[Q\]\]<sub>A(i)</sub>, i ∈ N} ∧ Ω ≠ ∅}_.
Example: _At what times was book X present in the library?_
4. **Cross-version join (CV)** joins the results of two queries (_Q1_ and _Q2_) between versions _V<sub>i</sub>_ and _V<sub>j</sub>_.
Formally: _VM(Q1, V<sub>i</sub>) ⨝ VM(Q2, V<sub>j</sub>)_.
Example: _What books were present in the library yesterday and today?_
5. **Change materialization (CM)** returns a list of versions in which a given query _Q_ produces
consecutively different results.
Formally: _{(i, j) | i,j ∈ ℕ, i < j, DM(Q, A(i), A(j)) = (Ω<sup>+</sup>, Ω<sup>−</sup>), Ω<sup>+</sup> ∪ Ω<sup>−</sup> ≠ ∅, ∄ k ∈ ℕ : i < k < j}_.
Example: _At what times was book X returned or taken from the library?_

There exists a correspondence between these query atoms
and the independent copies (IC), change-based (CB), and timestamp-based (TB) storage strategies.

Namely, VM queries are efficient in storage solutions that are based on IC, because there is indexing on version.
On the other hand, IC-based solutions may introduce a large amount of overhead in terms of storage space because each version is stored separately.
Furthermore, DM and VQ queries are less efficient for IC solutions.
That is because DM queries require two fully-materialized versions to be compared on-the-fly,
and VQ requires _all_ versions to be queried at the same time.

DM queries can be efficient in CB solutions if the query version ranges correspond to the stored delta ranges.
In all other cases, as well as for VM and VQ queries, the desired versions must be materialized on-the-fly,
which will take increasingly more time for longer delta chains.
CB solutions do however typically require less storage space than VM if there is sufficient overlap between each consecutive version.

Finally, VQ queries perform well for TB solutions because the timestamp annotation directly corresponds to VQ's result format.
VM and DM queries in this case are typically less efficient than for IC approaches, due to the missing version index.
Furthermore, TB solutions can require less storage space compared to VM if the change ratio of the dataset is not too large.

In summary, IC, CB and TB approaches can perform well for certain query types, but they can be slow for others.
On the other hand, this efficiency typically comes at the cost of a large storage overhead, as is the case for IC-based approaches.

[DIACHRON QL](cite:cites diachronql) is a SPARQL query language extension
based on the DIACHRON data model that provides functionality similar to these query atoms
in order to query specific versions, changesets, or all versions.
