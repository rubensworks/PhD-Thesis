### Abstract
{:#storing_abstract .no-label-increment}

<!-- Context      -->
When publishing Linked Open Datasets on the Web,
most attention is typically directed to their latest version.
Nevertheless, useful information is present in or between previous versions.
<!-- Need         -->
In order to exploit this historical information in dataset analysis,
we can maintain history in RDF archives.
Existing approaches either require much storage space,
or they expose an insufficiently expressive or efficient interface
with respect to querying demands.
<!-- Task         -->
In this article, we introduce an RDF archive indexing technique that is able to store datasets
with a low storage overhead,
by compressing consecutive versions and adding metadata for reducing lookup times.
<!-- Object       -->
We introduce algorithms based on this technique for efficiently evaluating
queries *at* a certain version, *between* any two versions, and *for* versions.
Using the BEAR RDF archiving benchmark,
we evaluate our implementation, called OSTRICH.
<!-- Findings     -->
Results show that OSTRICH introduces a new trade-off regarding storage space, ingestion time, and querying efficiency.
By processing and storing more metadata during ingestion time,
it significantly lowers the average lookup time for versioning queries.
OSTRICH performs better for many smaller dataset versions
than for few larger dataset versions.
Furthermore, it enables efficient offsets in query result streams,
which facilitates random access in results.
<!-- Conclusion   -->
Our storage technique reduces query evaluation time for versioned queries
through a preprocessing step during ingestion,
which only in some cases increases storage space when compared to other approaches.
This allows data owners to store and query multiple versions of their dataset efficiently,
<!-- Perspectives -->
lowering the barrier to historical dataset publication and analysis.
