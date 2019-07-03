### Discussion
{:#generating_discussion}

In this section, we discuss the main characteristics, the usage within benchmarks and the limitations of this work.
Finally, we mention several PoDiGG use cases.

#### Characteristics

Our main research question on how to generate realistic synthetic public transport networks
has been answered by the introduction of the mimicking algorithm from [](#generating_methodology),
based on commonly used practises in transit network design.
This is based on the accepted hypothesis that the population distribution
of an area is correlated with its transport network design and scheduling.
We measured the realism of the generated datasets using the coherence metric in [](#generating_subsec:evaluation:coherence)
and more fine-grained realism metrics for different public transport aspects in [](#generating_subsec:evaluation:distance).

PoDiGG, our implementation of the algorithm, accepts a wide range of parameters to configure the mimicking algorithm.
PoDiGG and PoDiGG-LC are able to output the mimicked data respectively as GTFS and RDF datasets,
together with a visualization of the generated transit network.
Our system can be used without requiring any extensive setup or advanced programming skills,
as it consists of simple command lines tools that can be invoked with a number of optional parameters to configure the generator.
Our system is proven to be generalizable to other transport types,
as we evaluated PoDiGG for the bus and train transport type,
and the Belgium and Netherlands geospatial regions in [](#generating_subsec:evaluation:distance).

#### Usage within Benchmarks

A~synthetic dataset generator,
which is one of the main contributions of this work,
forms an essential aspect of benchmarks for [(RDF) data management systems](cite:cites ldbc,benchmarkhandbook).
Prescribing a&nbsp;concrete benchmark that includes the evaluation of tasks is out of scope.
However,
to provide a guideline on how our dataset generator can be used as part of a benchmark,
we relate the primary elements of public transport datasets to *choke points* in data management systems,
i.e., key technical challenges in these system.
Below, we list choke points related to *storage* and *querying* within data management systems and route planning systems.
For each choke point, we introduce example tasks to evaluate them in the context of public transport datasets.
The querying choke points are inspired by the choke points identified by [Petzka et. al. for faceted browsing](cite:cites petzka2017benchmarking).

1. Storage of entities.
    1. Storage of stops, stations, connections, routes, trips and delays.
2. Storage of links between entities.
    1. Storage of stops per station.
    2. Storage of connections for stops.
    3. Storage of the next connection for each connection.
    4. Storage of connections per trip.
    5. Storage of trips per route.
    6. Storage of a connection per delay.
3. Storage of literals.
    1. Storage of latitude, longitude, platform code and code of stops.
    2. Storage of latitude, longitude and label of stations.
    3. Storage of delay durations.
    4. Storage of the start and end time of connections.
4. Storage of sequences.
    1. Storage of sequences of connections.
5. Find instances by property value.
    1. Find latitude, longitude, platform code or code by stop.
    2. Find station by stop.
    3. Find country by station.
    4. Find latitude, longitude, or label by station.
    5. Find delay by connection.
    6. Find next connection by connection.
    7. Find trip by connection.
    8. Find route by connection.
    9. Find route by trip.
6. Find instances by inverse property value.
    1. *Inverse of examples above.*
7. Find instances by a combination of properties values.
    1. Find stops by geospatial location.
    2. Find stations by geospatial location.
8. Find instances for a certain property path with a certain value.
    1. Find the delay value of the connection after a given connection.
    2. Find the delay values of all connections after a given connection.
9. Find instances by inverse property path with a certain value.
    1. Find stops that are part of a certain trip that passes by the stop at the given geospatial location.
10. Find instances by class, including subclasses.
    1. Find delays of a certain class.
11. Find instances with a numerical value within a certain interval.
    1. Find stops by latitude or longitude range.
    2. Find stations by latitude or longitude range.
    3. Find delays with durations within a certain range.
12. Find instances with a combination of numerical values within a certain interval.
    1. Find stops by geospatial range.
    2. Find stations by geospatial range.
13. Find instances with a numerical interval by a certain value for a certain property path.
    1. Find connections that pass by stops in a given geospatial range.
14. Find instances with a numerical interval by a certain value.
    1. Find connections that occur at a certain time.
15. Find instances with a numerical interval by a certain value for a certain property path.
    1. Find trips that occur at a certain time.
16. Find instances with a numerical interval by a certain interval.
    1. Find connections that occur during a certain time interval.
17. Find instances with a numerical interval by a certain interval for a certain property path.
    1. Find trips that occur during a certain time interval.
18. Find instances with numerical intervals by intervals with property paths.
    1. Find connections that occur during a certain time interval with stations that have stops in a given geospatial range.
    2. Find trips that occur during a certain time interval with stops in a given geospatial range.
    3. Plan a route that gets me from stop A to stop B starting at a certain time.

This list of choke points and tasks can be used
as a basis for benchmarking spatiotemporal data management systems 
using public transport datasets.
For example, SPARQL queries can be developed based on these tasks
and executed by systems using a public transport dataset.
For the benchmarking with these tasks, it is essential that the used datasets are realistic,
as discussed in [](#generating_subsec:evaluation:distance).
Otherwise, certain choke points may not resemble the real world.
For example, if an unrealistic dataset would contain only a single trip that goes over all stops,
then finding a route between two given stops could be unrealistically simple.

#### Limitations and Future Work

In this section, we discuss the limitations of the current mimicking algorithm and its implementation,
together with further research opportunities.

##### Memory Usage
The sequential steps in the presented mimicking algorithm require persistence of the intermediary data that is generated in each step.
Currently, PoDiGG is implemented in such a way that all data is kept in-memory for the duration of the generation, until it is serialized.
When large datasets need to be generated, this requires a larger amount of memory to be allocated to the generator.
Especially for large amounts of routes or connections, where 100 million connections already require almost 10GB of memory to be allocated.
While performance was not the primary concern in this work, in future work, improvements could be made in the future.
A first possible solution would be to use a memory-mapped database for intermediary data,
so that not all data must remain in memory at all times.
An alternative solution would be to modify the mimicking process to a streaming algorithm,
so that only small parts of data need to be kept in memory for datasets of any size.
Considering the complexity of transit networks, a pure streaming algorithm might not be feasible,
because route design requires knowledge of the whole network.
The generation of connections however, could be adapted so that it works as a streaming algorithm.

##### Realism
We aimed to produce realistic transit feeds by reusing the methodologies learned in public transit planning.
Our current evaluation compares generated output to real datasets, as no similar generators currently exist.
When similar generation algorithms are introduced in the future, this evaluation can be extended to compare their levels of realism.
Our results showed that all sub-generators, except for the trips generator, produced output with a high realism value.
The trips are still closer to real data than a random generator, but this can be further improved in future work.
This can be done by for instance taking into account [network capacities](cite:cites transitnetworkdesignscheduling)
on certain edges when instantiating routes as trips,
because we currently assume infinite edge capacities, which can result in a large amount of connections over an edge at the same time,
which may not be realistic for certain networks.
Alternatively, we could include other factors in the generation algorithm,
such as the location of certain points of interest, such as shopping areas, schools and tourist spots.
In the future, a study could be done to identify and measure the impact of certain points of interest on transit networks,
which could be used as additional input to the generation algorithm to further improve the level of realism.
Next to this, in order to improve [transfer coordination](cite:cites transitnetworkdesignscheduling),
possible transfers between trips should be taken into account when generating stop times.
Limiting the network capacity will also lead to [natural congestion of networks](cite:cites generatingnetworkbasedmovingobjects),
which should also be taken into account for improving the realism.
Furthermore, the [total vehicle fleet size](cite:cites transitnetworkdesignscheduling) should be considered,
because we currently assume an infinite number of available vehicles.
It is more realistic to have a limited availability of vehicles in a network,
with the last position of each vehicle being of importance when choosing the next trip for that vehicle.

##### Alternative Implementations
An alternative way of implementing this generator would be to define declarative dependency rules for public transport networks,
based on the work by [Pengyue et. al.](cite:cites syntheticidsgenerator). This would require a semantic extension to the engine
so that is aware of the relevant ontologies and that it can serialize to one or more RDF formats.
Alternatively, machine learning techniques could be used
to automatically learn the structure and characteristics of real datasets
and create [similar realistic synthetic datasets](cite:cites machinelearningsyntheticdataset),
or to [create variants of existing datasets](cite:cites machinelearningdatawarping).
The downside of machine learning techniques is however that it is typically more difficult to tweak parameters of automatically learned models
when specific characteristics of the output need to be changed, when compared to a manually implemented algorithm.
Sensitivity analysis could help to determine the impact of such parameters in order to understand the learned models better.

##### Streaming Extension
Finally, the temporal aspect of public transport networks is useful for the domain of [RDF stream processing](cite:cites streamreasoning).
Instead of producing single static datasets as output, PoDiGG could be adapted to produce RDF streams of connections and delays,
where information about stops and routes are part of the background knowledge.
Such an extension can become part of a benchmark, such as [CityBench](cite:cites citybench) and [LSBench](cite:cites lsbench),
for assessing the performance of RDF stream processing systems with temporal and geospatial capabilities.

#### PoDiGG In Use

PoDiGG and PoDiGG-LC have been developed for usage within the \hobbit platform.
This platform is being developed within the HOBBIT project and aims to provide
an environment for benchmarking RDF systems for Big Linked Data.
The platform provides several default dataset generators, including PoDiGG,
which can be used to benchmark systems.

PoDiGG, and its generated datasets are being used in the [ESWC Mighty Storage Challenge 2017 and 2018](cite:cites mocha2017).
The first task of this challenge consists of RDF data ingestion into triple stores,
and querying over this data.
Because of the temporal aspect of public transport data in the form of connections,
PoDiGG datasets are fragmented by connection departure time, and transformed to a data stream that can be inserted.
In task 4 of this challenge, the efficiency of [faceted browsing solutions is benchmarked](cite:cites petzka2017benchmarking).
In this work, a list of choke points are identified regarding SPARQL queries on triple stores,
which includes points such as the selection of subclasses and property-path transitions.
Because of the geographical property of public transport data, PoDiGG datasets are being used for this benchmark.

Finally, PoDiGG is being used for creating virtual transit networks of variable size
for the purposes of benchmarking route planning frameworks, such as [Linked Connections](cite:cites linkedconnections).
