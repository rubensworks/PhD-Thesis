### Conclusions
{:#storing_conclusions}

In this article, we introduced an RDF archive storage method with accompanied algorithms for evaluating VM, DM, and VQ queries,
with efficient result offsets.
Our novel storage technique is a hybrid of the IC/CB/TB approaches, because we store sequences of snapshots followed by delta chains.
The evaluation of our OSTRICH implementation shows that this technique offers a new trade-off in terms of ingestion time, storage size and lookup times.
By preprocessing and storing additional data during ingestion, we can reduce lookup times for VM, DM and VQ queries compared to CB and TB approaches.
Our approach requires less storage space than IC approaches, at the cost of slightly slower VM queries, but comparable DM queries.
Furthermore, our technique is faster than CB approaches, at the cost of more storage space.
Additionally, VQ queries become increasingly more efficient for datasets with larger amounts of versions compared to IC, CB and TB approaches.
Our current implementation supports a single snapshot and delta chain
as a proof of concept,
but production environments would normally incorporate more frequent snapshots,
balancing between storage and querying requirements.

With lookup times of 1ms or less in most cases, OSTRICH is an ideal candidate for Web querying,
as the network latency will typically be higher than that.
At the cost of increased ingestion times, lookups are fast.
Furthermore, by reusing the highly efficient HDT format for snapshots,
existing HDT files can directly be loaded by OSTRICH
and patched with additional versions afterwards.

OSTRICH fulfills the [requirements](cite:cites tpfarchives) for a backend RDF archive storage solution
for supporting versioning queries in the TPF framework.
Together with the [VTPF](cite:cites vtpf) interface feature, RDF archives can be queried on the Web at a low cost,
as demonstrated on [our public VTPF entrypoint](http://versioned.linkeddatafragments.org/bear){:.mandatory}.
TPF only requires triple pattern indexes with count metadata,
which means that TPF clients are able to evaluate full VM SPARQL queries using OSTRICH and VTPF.
In future work, the TPF client will be extended to also support DM and VQ SPARQL queries.

With OSTRICH, we provide a technique for publishing and querying RDF archives at Web-scale.
Several opportunities exist for advancing this technique in future work,
such as improving the ingestion efficiency, increasing the DM offset efficiency,
and supporting dynamic snapshot creation.
Solutions could be based on existing
[cost models](cite:cites designingarchivingpolicies) for determining whether a new snapshot or delta
should be created based on quantified time and space parameters.
Furthermore, branching and merging of different version chains can be investigated.

Our approach succeeds in reducing the cost for publishing RDF archives on the Web.
This lowers the barrier towards intelligent clients in the [Semantic Web](cite:cites semanticweb) that require *evolving* data,
with the goal of time-sensitive querying over the ever-evolving Web of data.
