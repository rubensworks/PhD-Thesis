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

I will discuss the findings within these challenges hereafter.

#### Generating Evolving Data

In [](#generating), the first challenge was tackled as a prerequisite for the next challenges.
The domain of public transport was chosen for this challenge,
as it contains both geospatial and temporal dimensions,
which makes it useful for benchmarking RDF data management systems that can handle various dimensions like these.
Even though many real-world public transit network design and scheduling methodologies already exist,
the synthetic generation of such datasets is not trivial.
The goal of this work was to determine wether or not population distributions could be used as input to such a mimicking algorithm.
Hence, this lead to the following [research question](#generating_researchquestion):

> Can population distribution data be used to generate realistic synthetic public transport networks and scheduling?

The main hypothesis of this work was: _public transport networks and schedules are correlated with the population distribution within the same area_.
This hypothesis was tested and validated for two countries with a high level of confidence.
As such, population distributions formed the basis of the mimicking algorithm of this work.

Inspired by real-world public transit network design and scheduling methodologies,
a multi-step algorithm was determined where regions, stops, edges, routes and trips are generated
based on any population distribution and dependency rules.
To evaluate the realism of generated datasets, an implementation of the algorithm was provided.
For each step in the algorithm, distance functions were determined to measure the realism for each step.
This realism was confirmed for different regions and transport types.

With the provided mimicking algorithm,
synthetic public transport networks and scheduling can be generated based on population distributions,
which answers our research question.
This tackles our initial challenge to support experimentation on systems that handle evolving knowledge graphs.

One could however question whether such domain-specific datasets are sufficient for testing evolving knowledge graphs systems in general.
As shown in [](#generating_methodology), the introduced data model contains a relatively small number of RDF properties and classes.
While large domain specific knowledge graphs like these are valuable,
domain-overlapping knowledge graphs such as [DBpedia](cite:cites dbpedia) and [Wikidata](cite:cites wikidata)
many more distinct properties and classes, which place additional demands on systems.
For such cases, multi-domain (evolving) knowledge graph generators could be created in future work.

#### Indexing Evolving Data

Next, in [](#storing), the challenge was to determine an approach
that achieves a trade-off between storage size and lookup efficiency
that is beneficial for publishing evolving knowledge graphs on the Web.
This approach had to enable a Web-friendly storage approach,
so that evolving knowledge graphs can be published on the Web without requiring very costly machines.
Previous work has shown that by restricting queries on servers to [triple pattern queries](cite:cites ldf),
and executing more complex queries client-side, server load can be reduced significantly.
As such, our work built upon this idea by focusing on _triple pattern queries_.
Furthermore, to reduce memory usage during query execution,
we focus on _streaming_ results with optional _offsets_.
Finally, we focus on three main versioned query atoms to support various kinds of temporal queries over evolving knowledge graphs.
This lead to the following [research question](#storing_researchquestion):

> How can we store RDF archives to enable efficient versioned triple pattern queries with offsets?

This research question is answered by introducing
(1) a storage technique for maintaining multiple versions of a knowledge graph
and (2) querying algorithms that can be used to efficiently extract data from these versions.
As was shown via our hypotheses, this storage technique is a hybrid of different existing storage approaches,
which lead to a trade-off between all of them in terms of storage requirements and querying efficiency.
Important to note is that the introduced storage technique is therefore not the most optimal for all situations.
For specific use cases where only very specific query types are required,
dedicated systems will likely be more efficient.
However, when the domain of queries is broad,
a more general-purpose like our approach is more fitting,
as this will lead to sufficiently fast query execution in most cases,
with acceptable storage requirements.

In conclusion, our storage approach can be used be used as a backend
for publishing evolving knowledge graphs through a low-cost triple pattern interface,
which has been illustrated via [_Versioned_ Triple Pattern Fragments](cite:cites vtpf)
on [http://versioned.linkeddatafragments.org/bear](http://versioned.linkeddatafragments.org/bear).
Future challenges include the handling of very large numbers of versions and improving ingestion efficiency,
which both could be resolved by dynamically creating intermediary snapshots within the delta chain.

#### Heterogeneous Web Interfaces

In [](#querying), the challenge on handling the heterogeneous nature of Web interfaces during querying was tackled.
This was done through the design and development of a highly modular *meta* query engine (Comunica)
that simplifies the handling of various kinds of sources,
and lowers the barrier for researching new query interfaces and algorithms.

In order for Comunica to be usable as a research platform,
its architecture needed to be flexible enough to handle the complete SPARQL 1.1 specification,
and support heterogeneous interfaces.
For this, the _actor_, _mediator_, and _publish-subscribe_ software patterns were applied
to achieve an architecture where task-specific actors form building blocks,
and buses and mediators are used to handle their inter-communication,
which can be wired together through _dependency injection_.

With Comunica, evaluating the performance of different query algorithms and other query-related approaches become more fair.
Query algorithms are typically compared by implementing them in separate systems,
which leads to confounding factors that may impact the performance results,
such as the use of different programming languages or software libraries.
As Comunica consists of small task-specific building blocks,
different algorithms become different instances of such building blocks,
which reduces confounding during experiments.

Comunica's architecture is flexible enough to go outside the realm of standard SPARQL.
It is for example usable to create an engine for [querying over evolving knowledge graphs](cite:cites mocha_2018).
Concretely, support for OSTRICH datasources from [](#storing) was implemented,
together with support for versioned queries.
For this, the streaming results capability of OSTRICH proved compatible and beneficial
to the streaming query evaluation of Comunica.

#### Publishing and Querying Evolving Data

Finally, [](#querying-evolving) handled the challenge on a query interface for evolving knowledge graphs.
The main goal of this work was to determine whether (part of) the effort for executing continuous queries
over evolving knowledge graphs could be moved from server to client,
in order to allow the server to handle more concurrent clients.
The outcome of this work was a polling-based Web interface for evolving knowledge graphs,
and a client-side algorithm that is able to perform continuous queries using this interface.

The first [research question](#querying-evolving_researchquestion1) of this work was:

> Can clients use volatility knowledge to perform more efficient continuous SPARQL query evaluation by polling for data?

This question was answered by annotating dynamic data server-side with time annotations,
and by introducing a client-side algorithm that can detect these annotations,
and determine a polling frequency for continuous query evaluation based on that.
By doing this, clients only have to re-download data from the server when it was changed.
Furthermore, static data only have to be downloaded once from the server when needed,
and can therefore optimally be cached by the client.
In practise, one could however argue that no data is never truly indefinitely _static_,
which is why practical implementations will require caches with a high maximum age for static data
when performing continuous querying over long periods of time.

Our second [research question](#querying-evolving_researchquestion2) was formulated as:

> How does the client and server load of our solution compare to alternatives?

This question was answered by comparing the server and client load
of our approach with state of the art server-side engines.
Results show a clear movement of load from server to client,
at the cost of increased bandwidth usage and execution time.
The benefit of this becomes especially clear when the number of concurrent clients increase.
The server load of our approach scales significantly better compared to other approaches for an increasing number of clients.
This is caused by the fact that each clients now helps with query execution,
which frees up a significant portion of server load.
Since multiple concurrent clients also lead to server requests for overlapping URLs,
a server cache should theoretically be beneficial as well.
However, follow-up work has shown that [such a cache leads to higher server load](cite:cites tpfqs2)
due to the high cost of cache invalidation over dynamic data.
This shows that caching dynamic data is unlikely to achieve overall performance benefits.
More intelligent caching techniques may lead to better efficiency,
by for example only caching data that will be valid for at least a given time period.

The final [research question](#querying-evolving_researchquestion3) was defined as:

> How do different time-annotation methods perform in terms of the resulting execution times?

Results have shown that by exploiting named graphs for annotating expiration times to dynamic data,
total execution times are the lowest compared to other annotation approaches.
This is caused by the fact that the named graphs approach leads to a lower amount of triples to be downloaded from the server.
And since bandwidth usage has a significant impact on query execution times,
the number of triples that need to be download have such an impact.

#### Overview

By investigating these four challenges,
our main research question can be answered.
Concretely, evolving knowledge graphs with a low volatility (order of minutes or slower)
can be made queryable on the Web through a low-cost polling-based interface,
with a hybrid snapshot/delta/timestamp-based storage system in the back end.
On top of this and other interfaces,
intelligent client-side query engines can perform continuous queries.
This comes at the cost of an increase in bandwidth usage and execution time,
but with a higher guarantee on result completeness as server availability is improved.
All of this can be evaluated thoroughly using synthetic evolving datasets
that can for example be generated with a mimicking algorithm for public transport network.

This proves that evolving knowledge graphs *can* be published and queried on the Web.
Furthermore, no high-cost Web infrastructure is needed to publish or query such graphs,
which lowers the barrier for smaller, *decentralized* evolving knowledge graphs to be published,
without having to be a giant company with a large budget.

### Future work

While I have formulated one possible answer the question
on how to store and query evolving knowledge graphs on the Web,
this is definitely not the *only* answer.
As such, further research is needed on all aspects.

Regarding the storage aspect, alternative techniques for storing evolving knowledge graphs
with different trade-offs will be useful for different scenarios.
On the one hand, dedicated storage techniques should be developed for low-end devices,
such as small sensors in the Internet of Things.
On the other hand, storage techniques should be developed for very high-end devices,
such as required for the infrastructure within nuclear reactors.

Furthermore, current storage solutions mainly focus on the *syntactical* querying over evolving knowledge graphs,
but they do not really consider the issue of [*semantic querying*](cite:cites semanticversioning) yet,
which involves taking into account the *meaning* of things through ontology-based inferencing.
Semantic querying over evolving knowledge graphs is needed to enable semantic analysis over such knowledge,
such as analyzing [concept drift](cite:cites conceptdrift) or [tracking diseases in biomedical datasets over time](cite:cites biomedical).
As such, the area of semantic querying over evolving knowledge graphs requires further research.

During this PhD, I mainly focused on publishing and querying evolving knowledge graphs
with predictable periodicity in the order of one minute.
Knowledge graphs with faster, slower or unpredictable periodicities may require different techniques.
As such, more work is needed to investigate the impact of different kinds of
evolving knowledge graphs on publishing and querying.
For instance, evolving knowledge graphs with slower periodicities may benefit more from being published
through an interface that is well cacheable, compared to more volatile knowledge graphs.

Next, standardization efforts will be needed to truly bring evolving knowledge graphs to the Web,
in the form of temporal query languages, temporal models and exchange formats.
For the sake of compatibility, these should be extensions or they should be representable
in the existing Linked Data stack, which will mainly impact RDF and SPARQL.
The [W3C RDF Stream Processing community group](https://www.w3.org/community/rsp/){:.mandatory}
is a first effort that aims to explore these issues.

Due to the many remaining challenges,
it will take more research and engineering effort before we will see
the true adoption of publishing and querying evolving knowledge graphs on the Web.
Nevertheless, it is important to open up these evolving knowledge graphs to the public Web,
so that humanity can benefit from this as whole,
instead of only being usable by organizations internally behind closed doors.

In a broader sense, more work will be needed to solve open problems with *decentralized* knowledge graphs.
The [Solid ecosystem](cite:cites solid) is becoming an important driver within this decentralization effort,
as it offers several fundamental standards to build a decentralized Web.
As such, future Web research will benefit significantly by building upon these standards.
Concretely, new techniques and algorithms are needed to
(1) intelligently navigate the the Web by [following relevant links for a given query](cite:cites linkeddataqueries),
(2) enable efficient querying over a *large number of sources*,
(3) allow *authentication-aware* querying over *private* data,
and (4) support *collaborative* querying between agents that handle similar queries.

Next to these technical issues, organizational and societal changes will also be needed.
For instance, the European General Data Protection Regulation places strict demands on companies that handle personal data.
Decentralization efforts such as Solid are being investigated by organizations
such as [governments to reshape the relationship with their citizens](cite:cites solid_gov),
by giving people true ownership over their data, and making governments data consumers.

As I placed a strong emphasis on *reusability* during this PhD,
all of the tools and experiments that were implemented
are available under an open license.
Furthermore, well-established development methods from the software industry were followed
to achieve implementations with decent code quality and valuable usage and development documentation.
This should therefore lower the barrier for other researchers in the future
to build upon this research and its tools.

For the next couple of years,
I aim to focus more on the topic of querying decentralized knowledge graphs.
For this, I will collaborate further with my colleagues from IDLab,
researchers from other labs,
and companies with similar goals.
With this, I hope to empower *individuals* on the Web,
by allowing them to find the information *they* want,
instead of what is being forced upon them,
which is [a fundamental human right](https://www.un.org/en/universal-declaration-human-rights/).
