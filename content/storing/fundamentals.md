### Overview of Approaches
{:#storing_fundamentals}

In this section, we lay the groundwork for the following sections.
We introduce fundamental concepts
that are required in our storage approach and its accompanying querying algorithms,
which will be explained in [](#storing_storage) and [](#storing_querying), respectively.

To combine smart use of storage space with efficient processing of VM, DM, and VQ triple pattern queries,
we employ a hybrid approach between the individual copies (IC), change-based (CB), and timestamp-based (TB) storage techniques (as discussed in [](#storing_related-work)).
In summary, intermittent _fully materialized snapshots_ are followed by _delta chains_.
Each delta chain is stored in _six tree-based indexes_, where values are dictionary-encoded and timestamped
to reduce storage requirements and lookup times.
These six indexes correspond to the combinations for storing three triple component orders
separately for additions and deletions.
The indexes for the three different triple component orders
ensure that any triple pattern query can be resolved quickly.
The additions and deletions are stored separately
because access patterns to additions and deletions in deltas differ between VM, DM, and VQ queries.
To efficiently support inter-delta DM queries, each addition and deletion value contains a _local change_ flag
that indicates if the change is not relative to the snapshot.
Finally, in order to provide cardinality estimation for any triple pattern,
we store an additional count data structure.

In the following sections, we discuss the most important distinguishing features of our approach.
We elaborate on the novel hybrid IC/CB/TB storage technique that our approach is based on,
the reason for using multiple indexes,
having local change metadata,
and methods for storing addition and deletion counts.

#### Snapshot and Delta Chain
{:#storing_snapshot-delta-chain}

Our storage technique is partially based on a hybrid IC/CB approach similar to [](#storing_regular-delta-chain).
To avoid increasing reconstruction times,
we construct the delta chain in an [aggregated deltas](cite:cites vmrdf) fashion:
each delta is _independent_ of a preceding delta and relative to the closest preceding snapshot in the chain, as shown in [](#storing_alternative-delta-chain).
Hence, for any version, reconstruction only requires at most one delta and one snapshot.
Although this does increase possible redundancies within delta chains,
due to each delta _inheriting_ the changes of its preceding delta,
the overhead can be compensated with compression, which we discuss in [](#storing_storage).

<figure id="storing_alternative-delta-chain">
<img src="storing/img/alternative-delta-chain.svg" alt="[alternative delta chain]" class="figure-medium-width">
<figcaption markdown="block">
Delta chain in which deltas are relative to the snapshot at the start of the chain, as part of our approach.
</figcaption>
</figure>

#### Multiple Indexes
{:#storing_indexes}

Our storage approach consists of six different indexes that are used for separately storing additions and deletions
in three different triple component orders, namely: `SPO`, `POS` and `OSP`.
These indexes are B+Trees, thereby, the starting triple for any triple pattern can be found in logarithmic time.
Consequently, the next triples can be found by iterating through the links between each tree leaf.
[](#triple-pattern-index-mapping) shows an overview of which triple patterns can be mapped to which index.
In contrast to [other approaches](cite:cites rdf3x,hexastore) that ensure certain triple orders,
we use three indexes instead of all six possible component orders,
because we only aim to reduce the iteration scope of the lookup tree for any triple pattern.
For each possible triple pattern,
we now have an index that locates the first triple component in logarithmic time,
and identifies the terminating element of the result stream without necessarily having iterate to the last value of the tree.
For some scenarios, it might be beneficial to ensure the order of triples in the result stream,
so that more efficient stream joining algorithms can be used, such as sort-merge join.
If this would be needed, `OPS`, `PSO` and `SOP` indexes could optionally be added
so that all possible triple orders would be available.

<figure id="storing_triple-pattern-index-mapping" class="table" markdown="1">

| Triple pattern | `SPO` | `SP?` | `S?O` | `S??` | `?PO` | `?P?` | `??O` | `???` |
| -------------- |-------|-------|-------|-------|-------|-------|-------|-------|
| **OSTRICH**    | `SPO` | `SPO` | `OSP` | `SPO` | `POS` | `POS` | `OSP` | `SPO` |
| **HDT-FoQ**    | `SPO` | `SPO` | `SPO` | `SPO` | `OPS` | `PSO` | `OPS` | `SPO` |

<figcaption markdown="block">
Overview of which triple patterns are queried inside which index in OSTRICH and HDT-FoQ.
</figcaption>
</figure>

Our approach could also act as a dedicated RDF archiving solution
without (necessarily efficient) querying capabilities.
In this case, only a single index would be required, such as `SPO`, which would reduce the required storage space even further.
If querying would become required afterwards,
the auxiliary `OSP` and `POS` indexes could still be derived from this main index
during a one-time, pre-querying processing phase.

This technique is similar to the [HDT-FoQ](cite:cites hdtfoq) extension for HDT that adds additional indexes to a basic HDT file
to enable faster querying for any triple pattern.
The main difference is that HDT-FoQ uses the indexes `OSP`, `PSO` and `OPS`,
with a different triple pattern to index mapping as shown in [](#storing_triple-pattern-index-mapping).
We chose our indexes in order to achieve a more balanced distribution from triple patterns to index,
which could lead to improved load balancing between indexes when queries are parallelized.
HDT-FoQ uses `SPO` for five triple pattern groups, `OPS` for two and `PSO` for only a single group.
Our approach uses `SPO` for 4 groups, `POS` for two and `OSP` for two.
Future work is needed to evaluate the distribution for real-world queries.
Additionally, the mapping from patterns `S?O` to index `SPO` in HDT-FoQ will lead to suboptimal query evaluation
when a large number of distinct predicates is present.

#### Local Changes
{:#storing_local-changes}

A delta chain can contain multiple instances of the same triple,
since it could be added in one version and removed in the next.
Triples that revert a previous addition or deletion within the same delta chain, are called _local changes_,
and are important for query evaluation.
Determining the locality of changes can be costly,
thus we pre-calculate this information during ingestion time and store it for each versioned triple,
so that this does not have to happen during query-time.

When evaluating version materialization queries by combining a delta with its snapshot,
all local changes should be filtered out.
For example, a triple `A` that was deleted in version 1, but re-added in version 2,
is cancelled out when materializing against version 2.
For delta materialization, these local changes should be taken into account,
because triple `A` should be marked as a deletion between versions 0 and 1,
but as an addition between versions 1 and 2.
Finally, for version queries, this information is also required
so that the version ranges for each triple can be determined.

#### Addition and Deletion counts
{:#storing_addition-deletion-counts}

Parts of our querying algorithms depend on the ability to efficiently count
the _exact_ number of additions or deletions in a delta.
Instead of naively counting triples by iterating over all of them,
we propose two separate approaches for enabling efficient addition and deletion counting in deltas.

For additions, we store an additional mapping from triple pattern and version to number of additions
so that counts can happen in constant time by just looking them up in the map.
For deletions, we store additional metadata in the main deletions tree.
Both of these approaches will be further explained in [](#storing_storage).
