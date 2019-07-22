## Conclusions
{:#conclusions}

The [research question of this PhD](#research-question) was defined as
*"How to store and query evolving knowledge graphs on the Web?"*
The answer to this question is neither simple nor complete.
In this final chapter,
I first summarize an answer to this question,
and I discuss future research efforts that are needed to advance this work further.

### Contributions

Based on my research question, I focussed on four main challenges:

1. **Experimentation requires *realistic* evolving data.**
2. **Indexing evolving data involves a *trade-off* between *storage size* and *lookup efficiency*.**
3. **The Web is highly *heterogeneous*.**
4. **Publishing *evolving* data via a *queryable interface* is costly.**

In [](#generating), the first challenge was tackled as a prerequisite for the next challenges.
The goal of this work was to come up with a way to generate realistic public transport network datasets
based on population distributions.
The outcome was an algorithm and implementation that achieve this goal.

Next, in [](#storing), the challenge was to determine an approach
that achieves a trade-off between storage size and lookup efficiency
that is beneficial for publishing evolving knowledge graphs on the Web.
The outcome of this work was
(1) a storage technique for maintaining multiple versions of a knowledge graph
and (2) querying algorithms that can be used to efficiently extract data from these versions.

In [](#querying), the challenge on handling the heterogeneous nature of the Web during querying was tackled.
This was done through the design and development of a highly modular *meta* query engine
that simplifies the handling of various kinds of sources,
and lowers the barrier for researching new query interfaces and algorithms.

Finally, [](#querying-evolving) handled the challenge on a query interface for evolving knowledge graphs.
The main goal of this work was to determine whether (part of) the effort for executing continuous queries
over evolving knowledge graphs could be moved from server to client,
in order to allow the server to handle more concurrent clients.
The outcome of this work was a polling-based Web interface for evolving knowledge graphs,
and a client-side algorithm that is able to perform continuous queries using this interface.

Through investigating these four challenges,
our research question can be answered.
Concretely, evolving knowledge graphs can be made queryable on the Web through a low-cost polling-based interface,
with a hybrid snapshot/delta/timestamp-based storage system in the back end.
On top of this and other interfaces,
intelligent client-side query engines can perform continuous queries.
This comes at the cost of an increase in bandwidth usage and execution time,
but with a higher guarantee on result completeness as server availability is improved.

This proves that evolving knowledge graphs *can* be published and queried on the Web.
Furthermore, no high-cost Web infrastructure is needed to publish or query such graphs,
which lowers the barrier for smaller, *decentralized* evolving knowledge graphs to be published,
without having to be a large entity with a large budget.

### Future work

While I have formulated one possible answer the question
on how to store and query evolving knowledge graphs on the Web,
this is definitely not the *only* answer.
As such, further research is needed on all aspects.

Regarding the storage aspect, alternative techniques for storing evolving knowledge graphs
with different trade-offs will be useful for different scenarios.
On the one hand, storage techniques could be developed for low-end devices,
such as small sensors in the Internet of Things.
On the other hand, storage techniques could be developed for very high-end devices,
such as required for the infrastructure within nuclear reactors.

Regarding querying, more work will be needed to solve open problems with *decentralized* knowledge graphs.
For example, new techniques and algorithms are needed to
(1) intelligently navigate the the Web by following relevant links for a given query,
(1) enable efficient querying over a *large number of sources*,
(2) allow *authentication-aware* querying over *private* data,
and (3) support *collaborative* querying between agents that handle similar queries.

As I put a strong emphasis on *reusability* during this PhD,
all of the tools and experiments that were implemented
are available under an open license.
Furthermore, accepted development methods from the software industry were followed
to achieve implementations with decent code quality and valuable usage and development documentation.
This should therefore lower the barrier for other researchers in the future
to build upon this research and its tools.

For the next couple of years,
I aim to focus more on the topic of querying decentralized knowledge graphs.
Through collaboration with my colleagues from IDLab,
researchers from other labs,
and companies with similar goals,
With this, I hope to empower people on the Web,
by allowing them to find the information *they* want,
instead of what is being forced upon them,
which is [a fundamental human right](https://www.un.org/en/universal-declaration-human-rights/).
