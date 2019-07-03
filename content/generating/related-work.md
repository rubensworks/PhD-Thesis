### Related Work
{:#generating_related-work}

In this section, we present the related work on spatiotemporal and RDF dataset generation,

Spatiotemporal database systems store instances that are described using an identifier, a spatial location and a timestamp.
In order to evaluate spatiotemporal indexing and querying techniques with datasets,
automatic means exist to [generate such datasets with predictable characteristics](cite:cites syntheticspatiotemporal).

[Brinkhoff](cite:cites generatingnetworkbasedmovingobjects) argues that moving objects tend to follow a predefined network.
Using this and other statements, he introduces a spatiotemporal dataset generator.
Such a network can be anything over which certain objects can move,
ranging from railway networks to air traffic connections.
The proposed parameter-based generator restricts the existence of the spatiotemporal objects to
a predefined time period $$\lbrack t_\text{min},t_\text{max})$$.
It is assumed that each edge in the network has a maximum allowed speed and capacity
over which objects can move at a certain speed.
The eventual speed of each object is defined by the maximum speed of its class,
the maximum allowed speed of the edge, and the congestion of the edge based on its capacity.
Furthermore, external events that can impact the movement of the objects, such as weather conditions,
are represented as temporal grids over the network, which apply a *decreasing factor* on the maximum speed of the objects in certain areas.
The existence of each object that is generated starts at a certain timestamp,
which is determined by a certain function,
and *dies* when it arrives at its destination.
The starting node of an object can be chosen based on three approaches:

* **dataspace-oriented approaches**: Selecting the nearest node to a position picked from a two-dimensional distribution function that maps positions to nodes.
* **region-based approaches**: Improvement of the data-space oriented approach where the data space is represented as a collection of cells, each having a certain chance of being the place of a starting node.
* **network-based approaches**: Selection of a network node based on a one-dimensional distribution function that assigns a chance to each node.

Determining the destination node using one of these approaches leads to non-satisfying results.
Instead, the destination is derived from the preferred length of a route.
Each route is determined as the fastest path to a destination, weighed by the external events.
Finally, the results are reported as either textual output, insertion into a database or a figure of the generated objects.
Compared to our work, this approach assumes a predefined network,
while our algorithm also includes the generation of the network.
For our work, we reuse the concepts of object speed and region-based node selection with relation to population distributions.

In order to improve the testability of Information Discovery Systems,
a [generic synthetic dataset generator](cite:cites syntheticidsgenerator) was developed
that is able to generate synthetic data based on declarative graph definitions.
This graph is based on objects, attributes and relationships between them.
The authors propose to generate new instances, such as people, based on a set of dependency rules.
They introduce three types of dependencies for the generation of instances:

* **independent**: Attribute values that are independent of other instances and attributes.
* **intra-record (horizontal) dependencies**: Attribute values depending on other values of the same instance.
* **inter-record (vertical) dependencies**: Relationships between different instances.

Their engine is able to accept such dependencies as part of a semantic graph definition,
and iteratively create new instances to form a synthetic dataset.
This tool however outputs non-RDF CSV files, which makes it impossible to directly use this system for
the generation of public transport datasets in RDF using existing ontologies.
For our public transport use case, individual entities such as stops, stations and connections
would be possible to generate up to a certain level using this declarative tool.
However, due to the underlying relation to population distributions
and specific restrictions for resembling real datasets,
declarative definitions are too limited.

The need for benchmarking RDF data management systems is illustrated by the existence of the [Linked Data Benchmark Council](cite:cites ldbc)
and the [HOBBIT H2020 EU project](http://project-hobbit.eu/){:.mandatory} for benchmarking of Big Linked Data.
RDF benchmarks are typically based on certain datasets that are used as input to the tested systems.
[Many of these datasets are not always very closely related to real datasets](cite:cites rdfbenchmarksdatasets),
which may result in conclusions drawn from benchmarking results that do not translate to system behaviours in realistic settings.

[Duan et al.](cite:cites rdfbenchmarksdatasets) argue that the realism of an RDF dataset can be measured
by comparing the *structuredness* of that dataset with a realistic equivalent.
The authors show that real-world datasets are typically less structured than their synthetic counterparts,
which can results in significantly different benchmarking results,
since this level of structuredness can have an impact on how certain data is stored in RDF data management systems.
This is because these systems may behave differently on datasets with different levels of structuredness,
as they can have certain optimizations for some cases.
In order to measure this structuredness, the authors introduce the *coherence*
metric of a dataset $$D$$ with a type system $$\mathcal{T}$$ that can be calculated as follows:

$$
\begin{aligned}
    CH(\mathcal{T}, D) = \sum_{\forall{T \in \mathcal{T}}} WT(CV(T, D)) * CV(T, D)
\end{aligned}
$$

The type system $$\mathcal{T}$$ contains all the RDF types that are present in a dataset.
$$CV(T, D)$$ represents the *coverage* of a type $$T$$ in a dataset $$D$$,
and is calculated as the fraction of type instances that set a value for all its properties.
The factor $$WT(CV(T, D))$$ is used to weight this sum,
so that the coherence is always a value between 0 and 1, with 1 representing a perfect structuredness.
A maximal coherence means that all instances in the dataset have values for all possible properties in the type system,
which is for example the case in relational databases without optional values.
Based on this metric, the authors introduce a generic method for creating variants of real datasets
with different sizes while maintaining a similar structuredness.
The authors describe a method to calculate the coverage value of this dataset,
which has been [implemented as a procedure in the Virtuoso RDF store](cite:cites socialnetworkdatasetgenerator).
As the goal of our work is to generate *realistic* RDF public transport datasets,
we will use this metric to compare the realism of generated datasets with real datasets.
As this high-level metric is used to define *realism* over any kind of RDF dataset,
we will introduce new metrics to validate the realism for specifically the case of public transport datasets.
