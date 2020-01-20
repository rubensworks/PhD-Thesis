### Evaluation
{:#storing_evaluation}

In this section, we evaluate our proposed storage technique and querying algorithms.
We start by introducing OSTRICH, an implementation of our proposed solution.
After that, we describe the setup of our experiments, followed by presenting our results.
Finally, we discuss these results.

#### Implementation
{:#storing_implementation}

OSTRICH stands for _Offset-enabled STore for TRIple CHangesets_,
and it is a software implementation of the storage and querying techniques described in this article
It is implemented in C/C++ and available on [GitHub](https://zenodo.org/record/883008){:.mandatory} under an open license.
In the scope of this work, OSTRICH currently supports a single snapshot and delta chain.
OSTRICH uses [HDT](cite:cites hdt) as snapshot technology as it conforms to all the [requirements](#storing_snapshot-storage) for our approach.
Furthermore, for our indexes we use [Kyoto Cabinet](http://fallabs.com/kyotocabinet/){:.mandatory},
which provides a highly efficient memory-mapped B+Tree implementation with compression support.
OSTRICH immediately generates the main `SPO` index and the auxiliary `OSP` and `POS` indexes.
In future work, OSTRICH could be modified to only generate the main index and delay auxiliary index generation to a later stage.
Memory-mapping is required so that not all data must be loaded in-memory when queries are evaluated,
which would not always be possible for large datasets.
For our delta dictionary, we extend HDT's dictionary implementation with adjustments to make it work with unsorted triple components.
We compress this delta dictionary with [gzip](http://www.gzip.org/), which requires decompression during querying and ingestion.
Finally, for storing our addition counts, we use the memory-mapped Hash Database of Kyoto Cabinet.

We provide a developer-friendly C/C++ API for ingesting and querying data based on an OSTRICH store.
Additionally, we provide command-line tools for ingesting data into an OSTRICH store,
or evaluating VM, DM or VQ triple pattern queries for any given limit and offset against a store.
Furthermore, we implemented [Node JavaScript bindings](https://zenodo.org/record/883010){:.mandatory} that
expose the OSTRICH API for ingesting and querying to JavaScript applications.
We used these bindings to [expose an OSTRICH store](http://versioned.linkeddatafragments.org/bear){:.mandatory}
containing a dataset with 30M triples in 10 versions using [TPF](cite:cites ldf), with the [VTPF feature](cite:cites vtpf).

#### Experimental Setup

As mentioned before in [](#storing_related-work-benchmarks), we evaluate our approach using the BEAR benchmark.
We chose this benchmark because it provides a complete set of tools and data for benchmarking RDF versioning systems,
containing datasets, queries and easy-to-use engines to compare with.

We extended the existing BEAR implementation for the evaluation of offsets.
We did this by implementing custom offset features into each of the BEAR approaches.
Only for VM queries in HDT-IC an efficient implementation (HDT-IC+) could be made because of HDT's native offset capabilities.
In all other cases, naive offsets had to be implemented by iterating over the result stream
until a number of elements equal to the desired offset were consumed.
This modified implementation is available on [GitHub](https://github.com/rdfostrich/bear/tree/ostrich-eval-journal){:.mandatory}.
To test the scalability of our approach for datasets with few and large versions, we use the BEAR-A benchmark.
We use the first ten versions of the BEAR-A dataset, which contains 30M to 66M triples per version.
This dataset was compiled from the [Dynamic Linked Data Observatory](http://swse.deri.org/dyldo/).
To test for datasets with many smaller versions, we use BEAR-B with the daily and hourly granularities.
The daily dataset contains 89 versions and the hourly dataset contains 1,299 versions,
both of them have around 48K triples per version.
We did not evaluate BEAR-B-instant, because OSTRICH requires increasingly
more time for each new version ingestion, as will be shown in the next section.
As BEAR-B-hourly with 1,299 versions already takes more than three days to ingest,
the 21,046 versions from BEAR-B-instant would require too much time to ingest.
All of our experiments were executed on a 64-bit
Ubuntu 14.04 machine with 128 GB of memory and a
24-core 2.40 GHz CPU.

For BEAR-A, we use all 7 of the provided querysets, each containing at most 50 triple pattern queries,
once with a high result cardinality and once with a low result cardinality.
These querysets correspond to all possible triple pattern materializations, except for triple patterns where each component is blank.
For BEAR-B, only two querysets are provided, those that correspond to `?P?` and `?PO` queries.
The number of BEAR-B queries is more limited, but they are derived from real-world DBpedia queries
which makes them useful for testing real-world applicability.
All of these queries are evaluated as VM queries on all versions,
as DM between the first version and all other versions,
and as VQ.

For a complete comparison with other approaches, we re-evaluated BEAR's Jena and HDT-based RDF archive implementations.
More specifically, we ran all BEAR-A queries against Jena with the IC, CB, TB and hybrid CB/TB implementation,
and HDT with the IC and CB implementations
using the BEAR-A dataset for ten versions.
We did the same for BEAR-B with the daily and hourly dataset.
After that, we evaluated OSTRICH for the same queries and datasets.
We were not able to extend this benchmark with other similar systems such as X-RDF-3X, RDF-TX and Dydra,
because the source code of systems was either not publicly available,
or the system would require additional implementation work to support the required query interfaces.

Additionally, we evaluated the ingestion rates and storage sizes for all approaches.
Furthermore, we compared the ingestion rate for the two different ingestion algorithms of OSTRICH.
The batch-based algorithm expectedly ran out of memory for larger amounts of versions,
so we used the streaming-based algorithm for all further evaluations.

Finally, we evaluated the offset capabilities of OSTRICH
by comparing it with custom offset implementations for the other approaches.
We evaluated the blank triple pattern query with offsets ranging from 2 to 4,096 with a limit of 10 results.

#### Results

In this section, we present the results of our evaluation.
We report the ingestion results, compressibility, query evaluation times for all cases and offset result.
All raw results and the scripts that were used to process them are available on [GitHub](https://github.com/rdfostrich/ostrich-bear-results/){:.mandatory}.

##### Ingestion

[](#storing_results-ingestion-size) and [](#storing_results-ingestion-time)
respectively show the storage requirements and ingestion times for the different approaches for the three different benchmarks.
For BEAR-A, the HDT-based approaches outperform OSTRICH in terms of ingestion time, they are about two orders of magniture faster.
Only HDT-CB requires slightly less storage space.
The Jena-based approaches ingest one order of magnitude faster than OSTRICH, but require more storage space.
For BEAR-B-daily, OSTRICH requires less storage space than all other approaches except for HDT-CB at the cost of slower ingestion.
For BEAR-B-hourly, only HDT-CB and Jena-CB/TB require about 8 to 4 times less space than OSTRICH.
For BEAR-B-daily and BEAR-B-hourly, OSTRICH even requires less storage space than gzip on raw N-Triples.

As mentioned in [](#storing_addition-counts), we use a threshold to define which addition count values should be stored,
and which ones should be evaluated at query time.
For our experiments, we fixed this count threshold at 200,
which has been empirically determined through various experiments as a good value.
For values higher than 200, the addition counts started having a noticable impact on the performance of count estimation.
This threshold value means that when a triple pattern has 200 matching additions,
then this count will be stored.
[](#storing_results-addition-counts) shows that the storage space of the addition count datastructure
in the case of BEAR-A and BEAR-B-hourly is insignificant compared to the total space requirements.
However, for BEAR-B-daily, addition counts take up 37.05% of the total size with still an acceptable absolute size,
as the addition and deletion trees require relatively less space,
because of the lower amount of versions.
Within the scope of this work, we use this fixed threshold of 200.
We consider investigating the impact of different threshold levels and methods for dynamically determining optimal levels future work.

[](#storing_results-ostrich-ingestion-rate-beara) shows an increasing ingestion rate for each consecutive version for BEAR-A,
while [](#storing_results-ostrich-ingestion-size-beara) shows corresponding increasing storage sizes.
Analogously, [](#storing_results-ostrich-ingestion-rate-bearb-hourly) shows the ingestion rate for BEAR-B-hourly,
which increases until around version 1100, after which it increases significantly.
[](#storing_results-ostrich-ingestion-size-bearb-hourly) shows faster increasing storage sizes.

[](#storing_results-ostrich-ingestion-rate-beara-compare) compares the BEAR-A ingestion rate of the streaming and batch algorithms.
The streaming algorithm starts of slower than the batch algorithm but grows linearly,
while the batch algorithm consumes a large amount of memory, resulting in slower ingestion after version 8 and an out-of-memory error after version 10.

<figure id="storing_results-ingestion-size" class="table" markdown="1">

| Approach        | BEAR-A                | BEAR-B-daily   | BEAR-B-hourly      |
| --------------- |----------------------:|---------------:|-------------------:|
| Raw (N-Triples) | 46,069.76             | 556.44         | 8,314.86           |
| Raw (gzip)      |  3,194.88             |  30.98         |   466.35           |
| OSTRICH         |  3,102.72             |  12.32         |   187.46           |
|                 | +1,484.80             |  +4.55         |  +263.13           |
| Jena-IC         | 32,808.96             | 415.32         | 6,233.92           |
| Jena-CB         | 18,216.96             |  42.82         |   473.41           |
| Jena-TB         | 82,278.4              |  23.61         | 3,678.89           |
| Jena-CB/TB      | 31,160.32             |  22.83         |    53.84           |
| HDT-IC          |  5,335.04             | 142.08         | 2,127.57           |
|                 | +1,494.69             |  +6.53         |   +98.88           |
| HDT-CB          | *2,682.88*            |  *5.96*        |   *24.39*          |
|                 |   +802.55             |  +0.25         |    +0.75           |

<figcaption markdown="block">
Storage sizes for each of the RDF archive approaches in MB with BEAR-A, BEAR-B-daily and BEAR-B-hourly.
The additional storage size for the auxiliary OSTRICH and HDT indexes are provided as separate rows.
The lowest sizes per dataset are indicated in italics.
</figcaption>
</figure>

<figure id="storing_results-ingestion-time" class="table" markdown="1">

| Approach        | BEAR-A | BEAR-B-daily  | BEAR-B-hourly |
| --------------- |-------:|--------------:|--------------:|
| OSTRICH         | 2,256  | 12.36         | 4,497.32      |
| Jena-IC         |   443  |  8.91         |  142.26       |
| Jena-CB         |   226  |  9.53         |  173.48       |
| Jena-TB         | 1,746  |  0.35         |   70.56       |
| Jena-CB/TB      |   679  |  0.35         |    0.65       |
| HDT-IC          |    34  |  0.39         |    5.89       |
| HDT-CB          |   *18* | *0.02*        |   *0.07*      |

<figcaption markdown="block">
Ingestion times (minutes) for each of the RDF archive approaches with BEAR-A, BEAR-B-daily and BEAR-B-hourly.
The lowest times per dataset are indicated in italics.
</figcaption>
</figure>

<figure id="storing_results-addition-counts" class="table" markdown="1">

| BEAR-A            | BEAR-B-daily   | BEAR-B-hourly      |
|------------------:|---------------:|-------------------:|
| 13.69 (0.29%)     | 6.25 (37.05%)  | 15.62 (3.46%)      |

<figcaption markdown="block">
Storage sizes of the OSTRICH addition count component in MB with BEAR-A, BEAR-B-daily and BEAR-B-hourly.
The percentage of storage space that this component requires compared to the complete store is indicated between brackets.
</figcaption>
</figure>

<figure id="storing_results-ostrich-ingestion-rate-beara">
<img src="storing/img/results-ostrich-ingestion-rate-beara.svg" alt="[bear-a ostrich ingestion rate]" height="150em" class="figure-medium-width">
<figcaption markdown="block">
OSTRICH ingestion durations for each consecutive BEAR-A version in minutes for an increasing number of versions,
showing a lineair growth.
</figcaption>
</figure>

<figure id="storing_results-ostrich-ingestion-size-beara">
<img src="storing/img/results-ostrich-ingestion-size-beara.svg" alt="[bear-a ostrich ingestion sizes]" height="150em" class="figure-medium-width">
<figcaption markdown="block">
Cumulative OSTRICH store sizes for each consecutive BEAR-A version in GB for an increasing number of versions,
showing a lineair growth.
</figcaption>
</figure>

<figure id="storing_results-ostrich-ingestion-rate-bearb-hourly">
<img src="storing/img/results-ostrich-ingestion-rate-bearb-hourly.svg" alt="[bear-b-hourly ostrich ingestion rate]" height="150em" class="figure-medium-width">
<figcaption markdown="block">
OSTRICH ingestion durations for each consecutive BEAR-B-hourly version in minutes for an increasing number of versions.
</figcaption>
</figure>

<figure id="storing_results-ostrich-ingestion-size-bearb-hourly">
<img src="storing/img/results-ostrich-ingestion-size-bearb-hourly.svg" alt="[bear-b-hourly ostrich ingestion sizes]" height="150em" class="figure-medium-width">
<figcaption markdown="block">
Cumulative OSTRICH store sizes for each consecutive BEAR-B-hourly version in GB for an increasing number of versions.
</figcaption>
</figure>

<figure id="storing_results-ostrich-compressability" class="table" markdown="1">

| Format        | Dataset  | Size      | gzip      | Savings  |
|---------------|----------|----------:|----------:|---------:|
| **N-Triples** | A        |46,069.76  | 3,194.88  | 93.07%   |
|               | B-hourly | 8,314.86  |   466.35  | 94.39%   |
|               | B-daily  |   556.44  |    30.98  | 94.43%   |
| **OSTRICH**   | A        | 3,117.64  | 2,155.13  | 95.32%   |
|               | B-hourly |   187.46  |    34.92  | 99.58%   |
|               | B-daily  |    12.32  |     3.35  | 99.39%   |
| **HDT-IC**    | A        | 5,335.04  | 1,854.48  | 95.97%   |
|               | B-hourly | 2,127.57  |   388.02  | 95.33%   |
|               | B-daily  |   142.08  |    25.69  | 95.33%   |
| **HDT-CB**    | A        | *2,682.88*|  *856.39* | *98.14%* |
|               | B-hourly |    *24.39*|    *2.86* | *99.96%* |
|               | B-daily  |     *5.96*|    *1.14* | *99.79%* |

<figcaption markdown="block">
Compressability using gzip for all BEAR datasets using OSTRICH, HDT-IC, HDT-CB and natively as N-Triples.
The columns represent the original size (MB), the resulting size after applying gzip (MB), and the total space savings.
The lowest sizes are indicated in italics.
</figcaption>
</figure>

<figure id="storing_results-ostrich-ingestion-rate-beara-compare">
<img src="storing/img/results-ostrich-ingestion-rate-beara-compare.svg" alt="[Comparison of ostrich ingestion algorithms]" height="150em" class="figure-medium-width">
<figcaption markdown="block">
Comparison of the OSTRICH stream and batch-based ingestion durations.
</figcaption>
</figure>

##### Compressibility

[](#storing_results-ostrich-compressability) presents the compressibility of datasets without auxiliary indexes,
showing that OSTRICH and the HDT-based approaches significantly improve compressibility compared to the original N-Triples serialization.
We omitted the results from the Jena-based approaches in this table,
as all compressed sizes were in all cases two to three times larger than the N-Triples compression.

##### Query Evaluation

Figures [24](#storing_results-beara-vm-sumary), [25](#storing_results-beara-dm-summary) and [26](#storing_results-beara-vq-summary) respectively
summarize the VM, DM and VQ query durations of all BEAR-A queries on the first ten versions of the BEAR-A dataset for the different approaches.
HDT-IC clearly outperforms all other approaches in all cases,
while the Jena-based approaches are orders of magnitude slower than the HDT-based approaches and OSTRICH in all cases.
OSTRICH is about two times faster than HDT-CB for VM queries, and slightly slower for both DM and VQ queries.
For DM queries, HDT-CB does however continuously become slower for larger versions, while the lookup times for OSTRICH remain constant.
From version 7, OSTRICH is faster than HDT-CB.
[Appendix A](https://rdfostrich.github.io/article-jws2018-ostrich/#appendix-bear-a){:.mandatory} contains more detailed plots for each BEAR-A queryset,
in which we can see that all approaches collectively become slower for queries with a higher result cardinality,
and that predicate-queries are also significantly slower for all approaches.

<figure id="storing_results-beara-vm-sumary">
<img src="storing/img/query/results_beara-vm-summary.svg" alt="[bear-a vm]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median BEAR-A VM query results for all triple patterns for the first 10 versions.
</figcaption>
</figure>

<figure id="storing_results-beara-dm-summary">
<img src="storing/img/query/results_beara-dm-summary.svg" alt="[bear-a dm]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median BEAR-A DM query results for all triple patterns from version 0 to all other versions.
</figcaption>
</figure>

<figure id="storing_results-beara-vq-summary">
<img src="storing/img/query/results_beara-vq-summary.svg" alt="[bear-a vq]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median BEAR-A VQ query results for all triple patterns.
</figcaption>
</figure>

Figures [27](#storing_results-bearb-daily-vm-sumary), [28](#storing_results-bearb-daily-dm-summary) and [29](#storing_results-bearb-daily-vq-summary)
contain the query duration results for the BEAR-B queries on the complete BEAR-B-daily dataset for the different approaches.
Jena-based approaches are again slower than both the HDT-based ones and OSTRICH.
For VM queries, OSTRICH is slower than HDT-IC, but faster than HDT-CB, which becomes slower for larger versions.
For DM queries, OSTRICH is faster than HDT-CB for the second half of the versions, and slightly faster HDT-IC.
The difference between HDT-IC and OSTRICH is however insignificant in this case, as can be seen in [Appendix B](https://rdfostrich.github.io/article-jws2018-ostrich/#appendix-bear-b-daily){:.mandatory}.
For VQ queries, OSTRICH is significantly faster than all other approaches.
[Appendix B](https://rdfostrich.github.io/article-jws2018-ostrich/#appendix-bear-b-daily){:.mandatory} contains more detailed plots for this case,
in which we can see that predicate-queries are again consistently slower for all approaches.

<figure id="storing_results-bearb-daily-vm-sumary">
<img src="storing/img/query/results_bearb-daily-vm-summary.svg" alt="[bear-b-daily vm]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median BEAR-B-daily VM query results for all triple patterns for the first 10 versions.
</figcaption>
</figure>

<figure id="storing_results-bearb-daily-dm-summary">
<img src="storing/img/query/results_bearb-daily-dm-summary.svg" alt="[bear-b-daily dm]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median BEAR-B-daily DM query results for all triple patterns from version 0 to all other versions.
</figcaption>
</figure>

<figure id="storing_results-bearb-daily-vq-summary">
<img src="storing/img/query/results_bearb-daily-vq-summary.svg" alt="[bear-b-daily vq]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median BEAR-B-daily VQ query results for all triple patterns.
</figcaption>
</figure>

Figures [30](#storing_results-bearb-hourly-vm-sumary), [31](#storing_results-bearb-hourly-dm-summary) and [32](#storing_results-hourly-daily-vq-summary)
show the query duration results for the BEAR-B queries on the complete BEAR-B-hourly dataset for all approaches.
OSTRICH again outperforms Jena-based approaches in all cases.
HDT-IC is faster for VM queries than OSTRICH, but HDT-CB is significantly slower, except for the first 100 versions.
For DM queries, OSTRICH is comparable to HDT-IC, and faster than HDT-CB, except for the first 100 versions.
Finally, OSTRICH outperforms all HDT-based approaches for VQ queries by almost an order of magnitude.
[Appendix C](https://rdfostrich.github.io/article-jws2018-ostrich/#appendix-bear-b-hourly){:.mandatory} contains the more detailed plots
with the same conclusion as before that predicate-queries are slower.

<figure id="storing_results-bearb-hourly-vm-sumary">
<img src="storing/img/query/results_bearb-hourly-vm-summary.svg" alt="[bear-b-hourly vm]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median BEAR-B-hourly VM query results for all triple patterns for the first 10 versions.
</figcaption>
</figure>

<figure id="storing_results-bearb-hourly-dm-summary">
<img src="storing/img/query/results_bearb-hourly-dm-summary.svg" alt="[bear-b-hourly dm]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median BEAR-B-hourly DM query results for all triple patterns from version 0 to all other versions.
</figcaption>
</figure>

<figure id="storing_results-bearb-hourly-vq-summary">
<img src="storing/img/query/results_bearb-hourly-vq-summary.svg" alt="[bear-b-hourly vq]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median BEAR-B-hourly VQ query results for all triple patterns.
</figcaption>
</figure>

##### Offset

From our evaluation of offsets, [](#storing_results-offset-vm) shows that OSTRICH offset evaluation remain below 1ms,
while other approaches grow beyond that for larger offsets, except for HDT-IC+.
HDT-CB, Jena-CB and Jena-CB/TB are not included in this and the following figures
because they require full materialization before offsets can be applied, which is expensive and therefore take a very long time to evaluate.
For DM queries, all approaches have growing evaluation times for larger offsets including OSTRICH, as can be seen in [](#storing_results-offset-dm).
Finally, OSTRICH has VQ evaluation times that are approximately independent of the offset value,
while other approaches again have growing evaluation times, as shown in [](#storing_results-offset-vq).

<figure id="storing_results-offset-vm">
<img src="storing/img/query/results_offsets-vm.svg" alt="[Offsets vm]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median VM query results for different offsets over all versions in the BEAR-A dataset.
</figcaption>
</figure>

<figure id="storing_results-offset-dm">
<img src="storing/img/query/results_offsets-dm.svg" alt="[Offsets dm]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median DM query results for different offsets between version 0 and all other versions in the BEAR-A dataset.
</figcaption>
</figure>

<figure id="storing_results-offset-vq">
<img src="storing/img/query/results_offsets-vq.svg" alt="[Offsets vq]" height="200em" class="figure-medium-width">
<figcaption markdown="block">
Median VQ query results for different offsets in the BEAR-A dataset.
</figcaption>
</figure>

#### Discussion

In this section, we interpret and discuss the results from previous section.
We discuss the ingestion, compressibility, query evaluation, offset efficiency and test our hypotheses.

##### Ingestion

For all evaluated cases, OSTRICH requires less storage space than most non-CB approaches.
The CB and CB/TB approaches in most cases outperform OSTRICH in terms of storage space efficiency due
to the additional metadata that OSTRICH stores per triple.
Because of this, most other approaches require less time to ingest new data.
These timing results should however be interpreted correctly,
because all other approaches receive their input data in the appropriate format (IC, CB, TB, CB/TB),
while OSTRICH does not.
OSTRICH must convert CB input at runtime to the alternative CB structure where deltas are relative to the snapshot,
which explains the larger ingestion times.
As an example, [](#storing_triples-bearb-hourly-altcb) shows the number of triples in each BEAR-B-hourly version
where the deltas have been transformed to the alternative delta structure that OSTRICH uses.
Just like the first part of [](#storing_results-ostrich-ingestion-rate-bearb-hourly), this graph also increases linearly,
which indicates that the large number of triples that need to be handled for long delta chains is one of the main bottlenecks for OSTRICH.
This is also the reason why OSTRICH has memory issues during ingestion at the end of such chains.
One future optimization could be to maintain the last version of each chain in a separate index for faster patching.
Or a new ingestion algorithm could be implemented that accepts input in the correct alternative CB format.
Alternatively, a new snapshot can dynamically be created when ingestion time becomes too large,
which could for example for BEAR-B-hourly take place around version 1000.

<figure id="storing_triples-bearb-hourly-altcb">
<img src="storing/img/triples-bearb-hourly-altcb.svg" alt="[bear-b-hourly alternative cb]" height="150em" class="figure-medium-width">
<figcaption markdown="block">
Total number of triples for each BEAR-B-hourly version when converted to the alternative CB structure used by OSTRICH,
i.e., each triple is an addition or deletion relative to the _first_ version instead of the _previous_ version.
</figcaption>
</figure>

The BEAR-A and BEAR-B-hourly datasets indicate the limitations of the ingestion algorithm in our system.
The results for BEAR-A show that OSTRICH ingests slowly for many very large versions,
but it is still possible because of the memory-efficient streaming algorithm.
The results for BEAR-B-hourly show that OSTRICH should not be used when the number of versions is very large.
Furthermore, for each additional version in a dataset, the ingestion time increases.
This is a direct consequence of our alternative delta chain method where all deltas are relative to a snapshot.
That is the reason why when new deltas are inserted,
the previous one must be fully materialized by iterating over all existing triples,
because no version index exists.

In [](#storing_results-ostrich-ingestion-rate-bearb-hourly), we can observe large fluctuations in ingestion time around version 1,200 of BEAR-B-hourly.
This is caused by the large amount of versions that are stored for each tree value.
Since each version requires a mapping to seven triple pattern indexes and one local change flag in the deletion tree,
value sizes become non-negligible for large amounts of versions.
Each version value requires 28 uncompressed bytes,
which results in more than 32KB for a triple in 1,200 versions.
At that point, the values start to form a bottleneck as only 1,024 elements
can be loaded in-memory using the default page cache size of 32MB,
which causes a large amount of swapping.
This could be solved by either tweaking the B+Tree parameters for this large amount of versions,
reducing storage requirements for each value,
or by dynamically creating a new snapshot.

We compared the streaming and batch-based ingestion algorithm in [](#storing_results-ostrich-ingestion-rate-beara-compare).
The batch algorithm is initially faster because most operations can happen in memory,
while the streaming algorithm only uses a small fraction of that memory,
which makes the latter usable for very large datasets that don't fit in memory.
In future work, a hybrid between the current streaming and batch algorithm could be investigated,
i.e., a streaming algorithm with a larger buffer size, which is faster, but doesn't require unbounded amounts of memory.

##### Compressibility

As shown in [](#storing_results-ostrich-compressability),
when applying gzip directly on the raw N-Triples input, this already achieves significant space savings.
However, OSTRICH, HDT-IC and HDT-CB are able to reduce the required storage space _even further_ when they are used as a preprocessing step before applying gzip.
This shows that these approaches are better—storage-wise—for the archival of versioned datasets.
This table also shows that OSTRICH datasets with more versions are more prone to space savings
using compression techniques like gzip compared to OSTRICH datasets with fewer versions.

##### Query Evaluation

The results from previous section show that the OSTRICH query evaluation efficiency is faster than all Jena-based approaches,
mostly faster than HDT-CB, and mostly slower than HDT-IC.
VM queries in OSTRICH are always slower than HDT-IC,
because HDT can very efficiently query a single materialized snapshot in this case,
while OSTRICH requires more operations for materializing.
VM queries in OSTRICH are however always faster than HDT-CB, because the latter has to reconstruct complete delta chains,
while OSTRICH only has to reconstruct a single delta relative to the snapshot.
For DM queries, OSTRICH is slower or comparable to HDT-IC, slower than HDT-CB for early versions, but faster for later versions.
This slowing down of HDT-CB for DM queries is again caused by reconstruction of delta chains.
For VQ queries, OSTRICH outperforms all other approaches for datasets with larger amounts of versions.
For BEAR-A, which contains only 10 versions in our case,
the HDT-based approaches are slightly faster because only a small amount of versions need to be iterated.

##### Offsets

One of our initial requirements was to design a system that allows efficient offsetting of VM, DM and VQ result streams.
As shown in last section, for both VM and VQ queries, the lookup times for various offsets remain approximately constant.
For VM queries, this can fluctuate slightly for certain offsets due to the loop section inside the VM algorithm
for determining the starting position inside the snapshot and deletion tree.
For DM queries, we do however observe an increase in lookup times for larger offsets.
That is because the current DM algorithm naively offsets these streams by iterating
over the stream until a number of elements equal to the desired offset have been consumed.
Furthermore, other IC and TB approaches outperform OSTRICH's DM result stream offsetting.
This introduces a new point of improvement for future work,
seeing whether or not OSTRICH would allow more efficient DM offsets by adjusting either the algorithm or storage format.

##### Hypotheses

In [](#storing_problem-statement), we introduced six hypotheses, which we will validate in this section based on our experimental results.
We will only consider the comparison between OSTRICH and HDT-based approaches,
as OSTRICH outperforms the Jena-based approaches for all cases in terms of lookup times.
These validations were done using R, for which the source code can be found on [GitHub](https://github.com/rdfostrich/ostrich-bear-results/){:.mandatory}.
Tables containing p-values of the results can be found in [Appendix E](https://rdfostrich.github.io/article-jws2018-ostrich/#appendix-tests){:.mandatory}.

For our [first hypothesis](#storing_hypothesis-qualitative-querying), we expect OSTRICH lookup times to remain independent of version for VM and DM queries.
We validate this hypothesis by building a linear regression model with as response the lookup time,
and as factors version and number of results.
The [appendix (E)](https://rdfostrich.github.io/article-jws2018-ostrich/#hypo-test-1){:.mandatory} contains the influence of each factor, which shows that for all cases,
we can accept the null hypothesis that the version factor has no influence on the models with a confidence of 99%.
Based on these results, we *accept* our [first hypothesis](#storing_hypothesis-qualitative-querying).

<meta property="lsc:confirms" resource="#storing_hypothesis-qualitative-querying">

[Hypothesis 2](#storing_hypothesis-qualitative-ic-storage) states that OSTRICH requires *less* storage space than IC-based approaches,
and [Hypothesis 3](#storing_hypothesis-qualitative-ic-querying) correspondingly states that
query evaluation is *slower* for VM and *faster* or *equal* for DM and VQ.
Results from previous section showed that for BEAR-A, BEAR-B-daily and BEAR-B-hourly,
OSTRICH requires *less* space than HDT-IC, which means that we *accept* Hypothesis 2.
In order to validate that query evaluation is slower for VM but faster or equal for DM and VQ,
we compared the means using the independent two-group t-test, for which the results can be found in the [appendix (E)](https://rdfostrich.github.io/article-jws2018-ostrich/#hypo-test-2){:.mandatory}.
Normality of the groups was determined using the Kolmogorov-Smirnov test, for which p-values of 0.00293 or less were found.
In all cases, the means are not equal with a confidence of 95%.
For BEAR-B-daily and BEAR-B-hourly, HDT-IC is faster for VM queries, but slower for DM and VQ queries.
For BEAR-A, HDT-IC is faster for all query types.
We therefore *reject* Hypothesis 3, as it does not apply for BEAR-A, but it is valid for BEAR-B-daily and BEAR-B-hourly.
This means that OSTRICH typically requires less storage space than IC-based approaches,
and outperforms other approaches in terms of querying efficiency
unless the number of versions is small or for VM queries.

<meta property="lsc:confirms" resource="#storing_hypothesis-qualitative-ic-storage">
<meta property="lsc:falsifies" resource="#storing_hypothesis-qualitative-ic-querying">

In [Hypothesis 4](#storing_hypothesis-qualitative-cb-storage), we stated that OSTRICH requires *more*
storage space than CB-based approaches,
and in [Hypothesis 5](#storing_hypothesis-qualitative-cb-querying) that query evaluation is *faster* or *equal*.
In all cases OSTRICH requires more storage space than HDT-CB, which is why we *accept* Hypothesis 4.
For the query evaluation, we again compare the means in the [appendix (E)](https://rdfostrich.github.io/article-jws2018-ostrich/#hypo-test-3){:.mandatory} using the same test.
In BEAR-A, VQ queries in OSTRICH are not faster for BEAR-A, and VM queries in OSTRICH are not faster for BEAR-B-daily,
which is why we *reject* Hypothesis 5.
However, only one in three query atoms are not fulfilled, and OSTRICH is faster than HDT-CB for BEAR-B-hourly.
In general, OSTRICH requires more storage space than CB-based approaches,
and query evaluation is faster unless the number of versions is low.

<meta property="lsc:confirms" resource="#storing_hypothesis-qualitative-cb-storage">
<meta property="lsc:falsifies" resource="#storing_hypothesis-qualitative-cb-querying">

Finally, in our [last hypothesis](#storing_hypothesis-qualitative-ingestion),
we state that average query evaluation times are lower than other non-IC approaches at the cost of increased ingestion times.
In all cases, the ingestion time for OSTRICH is higher than the other approaches,
and as shown in the [appendix (E)](https://rdfostrich.github.io/article-jws2018-ostrich/#hypo-test-3){:.mandatory}, query evaluation times for non-IC approaches are lower for BEAR-B-hourly.
This means that we *reject* Hypothesis 6 because it only holds for BEAR-B-hourly and not for BEAR-A and BEAR-B-daily.
In general, OSTRICH ingestion is slower than other approaches,
but improves query evaluation time compared to other non-IC approaches,
unless the number of versions is low.

<meta property="lsc:falsifies" resource="#storing_hypothesis-qualitative-ingestion">

In this section, we accepted three of the six hypotheses.
As these are statistical hypotheses, these do not necessarily indicate negative results of our approach.
Instead, they allow us to provide general guidelines on where our approach can be used effectively, and where not.
