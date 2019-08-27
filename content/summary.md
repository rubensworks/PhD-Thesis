## Summary
{:#summary}

Over the last 30 years, the Web has significantly enhanced the way we share information,
which has lead to major transformations of our society.
Initially, information on the Web was targeted at humans,
and machines had a difficult time understanding information on the Web
in the same way as humans can.
This hindered *intelligent agents* to perform certain tasks autonomously,
such as finding all stores that sell rice in the current area,
or determining the time to leave for catching your flight on time based on the current traffic and weather conditions.
To enable such intelligent agents, researchers have been investigating technologies and introducing standards
for making the Web understandable for machines.
In the recent years, these technologies are being used to build so-called *knowledge graphs*,
which are collections of structured information to support intelligent agents such as Siri and Google Now.

Most research on knowledge graphs has been focused on *static* data.
However, there is however a huge amount of *evolving* data available,
such as traffic events from highway sensors or continuous heart rate measurements.
There is a lot of value in evolving knowledge,
such as for example the ability to determine daily busy traffic periods,
or sending alerts when the heart rate is too high for an unexpectedly long period of time.
As such, it is important to *store* this information in *evolving knowledge graphs*,
and to make it *searchable*.

Just like the Web, knowledge graphs are continuously becoming more and more *centralized*,
which means that information becomes increasingly more in the hands of a few large entities.
This leads to information only having limited availability for the public,
which endangers the democratic and *decentralized* nature of the Web.
Events in recent years have shown that centralizing information at this scale is problematic,
as it leads to issues such as censorship and manipulation of information.
For these reasons, there is an ongoing effort to *re-decentralize* the Web,
to make the Web a democratic platform again by giving back the power to the people.
As such, an underlying focus within my research is to enable this decentralization and democratization
of information on the Web,
in the form of knowledge graphs.

To facilitate the usage of *evolving knowledge graphs*,
**the goal of this PhD is to allow *evolving* knowledge graphs to be *stored* and *queried* on the *Web*.**
In the scope of this PhD, I consider knowledge graphs that evolve with a periodicity in the order of minutes or slower.
To investigate this topic, I focus on four challenges related to this topic.
First, to allow systems that handle evolving knowledge graphs to be evaluated,
I look into the *generation of evolving data*.
Secondly, I investigate methods to *store evolving data*,
so that the data can be published and queried on the Web efficiently.
Third, I design a flexible system to *query* various kinds of data on the *Web*.
Finally, I investigate methods for *publishing and querying evolving data on the Web*.

In order to properly evaluate systems that handle evolving knowledge graphs,
one must first *have* evolving knowledge graphs to test these systems with.
As existing evolving knowledge graphs are limited to having only specific sizes,
they are unsuited for the needs of extensive system evaluations,
where configurable evolving knowledge graph sizes are required.
This is why this first challenge focuses on the generation of evolving data, as a prerequisite to the next challenges.
Concretely, an algorithm is designed to generate synthetic public transport network datasets,
based on population distributions as input.
This algorithm is implemented and evaluated in terms of realism and performance.
Results show that this algorithm is valuable for evaluating systems that handle evolving knowledge graphs,
while still guaranteeing that the datasets are sufficiently realistic with respect to real-world analogues.

The second challenge focuses on investigating a Web-friendly trade-off between storage size and query efficiency
for evolving knowledge graphs.
For this, a storage approach was designed that can index evolving data,
and accompanying algorithms were developed for querying over this evolving data in an efficient manner.
The index is based on a hybrid between different kinds of storage mechanisms,
to enable efficient lookups for different temporal access patterns.
The query algorithms supports *offsets* and *limits*,
to enable random access to subsets of query results,
which is important for Web-friendly query interfaces.
Based on an implementation of this storage approach and querying algorithms,
experimental results show that this system achieves a trade-off between storage size and query efficiency
that is useful for hosting evolving knowledge graphs on the Web.
Concretely, query execution time is reduced at the cost of an increase in storage size.
This cost is acceptable due to storage typically being cheap.

In the third challenge, the *heterogeneous* nature of the Web is investigated.
Concretely, a query engine (Comunica) is designed that can query over various kinds of Web interfaces,
based on different kinds of query algorithms.
The engine is designed in a modular way,
so that new interfaces and algorithms can be developed and plugged in flexibly.
This also allows different approaches to be compared fairly,
which makes it a useful research platform.

Finally, the last challenge ties everything together,
and focuses on publishing evolving data on the Web via a queryable interface.
Concretely, we introduce a query interface for evolving data,
and a client-side algorithm for continuous querying over this interface in a polling-based manner.
This is done by annotating evolving data server-side with predetermined expiration times,
so that clients can determine the optimal polling frequency,
and non-expired data can be reused when other more volatile data expires.
Results show that this approach achieves a lower server load compared to fully server-side continuous query engines,
at the cost of an increase in execution time and bandwidth usage.

Within these four challenges,
methods are designed to allow evolving knowledge graphs to be stored and queried
in a Web-friendly way.
Concretely, evolving knowledge graphs can be stored in the hybrid storage system from challenge two.
On top of this, a low-cost temporal Web interface can be setup such as the one designed for the fourth challenge,
which can then be queried client-side to reduce server load as seen in challenge three and four.
All of this can then be evaluated using synthetic evolving knowledge graphs
as generated with the algorithm from challenge one.

While this PhD shows a way to store and query evolving knowledge graphs on the Web,
there does not exist a single perfect way to achieve this,
and different trade-offs exist for different solutions.
For example, storing evolving knowledge graphs over small, slowly evolving IoT sensors
may involve restricted storage capabilities.
On the other hand, highly volatile and sensitive sensors within nuclear reactor infrastructure
may require massive storage capabilities.
In the future, more research will be needed to come up with techniques to store and query
these various kinds of evolving knowledge graphs on the Web.
