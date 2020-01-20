### Method
{:#generating_methodology}

In order to formulate an answer to our research question,
we designed a mimicking algorithm that generates realistic synthetic public transit feeds.
We based it on techniques from the domains of public transit planning, spatiotemporal and RDF dataset generation.
We reuse the route design, frequencies setting and timetabling steps from the domain public transit planning,
but prepend this with a network generation phase.

[](#generating_fig:methodology:datamodel) shows the model of the generated public transit feeds,
with connections being the primary data element.

<figure id="generating_fig:methodology:datamodel">
<img src="generating/img/datamodel.svg" alt="PoDiGG data model" class="figure-medium">
<figcaption markdown="block">
The resources (rectangle), literals (dashed rectangle) and properties (arrows) used to model the generated public transport data.
Node and text colors indicate vocabularies.
</figcaption>
</figure>

We consider different properties in this model based on the [independent, intra-record or inter-record dependency rules](cite:cites syntheticidsgenerator), as discussed in [](#generating_related-work).
The arrival time in a connection can be represented as a fully intra-record dependency,
because it depends on the time it departed and the stops it goes between.
The departure time in a connection is both an intra-record and inter-record dependency,
because it depends on the stop at which it departs,
but also on the arrival time of the connection before it in the trip.
Furthermore, the delay value can be seen as an inter-record dependency,
because it is influenced by the delay value of the previous connection in the trip.
Finally, the geospatial location of a stop depends on the location of its parent station,
so this is also an inter-record dependency.
All other unmentioned properties are independent.

In order to generate data based on these dependency rules, our algorithm is subdivided in five steps:

1. **Region**: Creation of a two-dimensional area of cells annotated with population density information.
2. **Stops**: Placement of stops in the area.
3. **Edges**: Connecting stops using edges.
4. **Routes**: Generation of routes between stops by combining edges.
5. **Trips**: Scheduling of timely trips over routes by instantiating connections.

These steps are not fully sequential, since stop generation is partially executed before and after edge generation.
The first three steps are required to generate a network,
step 4 corresponds to the route design step in public transit planning
and step 5 corresponds to both the frequencies setting and timetabling.
These steps are explained in the following subsections.

#### Region

In order to create networks, we sample geographic regions in which such networks exist as two-dimensional matrices.
The resolution is defined as a configurable number of cells per square of one latitude by one longitude.
Network edges are then represented as links between these cells.
Because our algorithm is population distribution-based, each cell contains a population density.
These values can either be based on real population information from countries,
or this can be generated based on certain statistical distributions.
For the remainder of this paper, we will reuse the population distribution from Belgium as a running example, as illustrated in [](#generating_fig:methodology:region).

<figure id="generating_fig:methodology:region">
<img src="generating/img/region.png" alt="Heatmap of the population distribution in Belgium" class="figure-medium">
<figcaption markdown="block">
Heatmap of the population distribution in Belgium, which is illustrated for each cell
as a scale going from white (low), to red (medium) and black (high).
The actual placement of train stops are indicated as green points.
</figcaption>
</figure>

#### Stops

Stop generation is divided into two steps.
First, stops are placed based on population values,
then the edge generation step is initiated
after which the second phase of stop generation is executed where additional stops are created based on the generated edges.

**Population-based**
For the initial placement of stops, our algorithm only takes a population distribution as input.
The algorithm iteratively selects random cells in the two-dimensional area, and tags those cells as stops.
To make it [region-based](cite:cites generatingnetworkbasedmovingobjects),
the selection uses a weighted Zipf-like-distribution, where cells with high population values have a higher chance
of being picked than cells with lower values.
The shape of this Zipf curve can be scaled to allow for different stop distributions to be configured.
Furthermore, a minimum distance between stops can be configured, to avoid situations where all stops are placed in highly populated areas.

**Edge-based**
Another stop generation phase exists after the edge generation
because real transit networks typically show line artifacts for stop placement.
[](#generating_fig:methodology:stopplacementgs) shows the actual train stops in Belgium, which clearly shows line structures.
Stop placement after the first generation phase results can be seen in [](#generating_fig:methodology:stopplacementp1),
which does not show these line structures.
After the second stop generation phase, these line structures become more apparent as can be seen in [](#generating_fig:methodology:stopplacementp2).

<figure id="generating_fig:methodology:stopplacement">

<figure id="generating_fig:methodology:stopplacementgs" class="subfigure">
<img src="generating/img/stops_gs.png" alt="Real stops">
<figcaption markdown="block">
Real stops with line structures.
</figcaption>
</figure>

<figure id="generating_fig:methodology:stopplacementp1" class="subfigure">
<img src="generating/img/stops_parameterized_1.png" alt="Generation phase step 1">
<figcaption markdown="block">
Synthetic stops after the first stop generation phase without line structures.
</figcaption>
</figure>

<figure id="generating_fig:methodology:stopplacementp2" class="subfigure">
<img src="generating/img/stops_parameterized_2.png" alt="Generation phase step 2">
<figcaption markdown="block">
Synthetic stops after the second stop generation phase with line structures.
</figcaption>
</figure>

<figcaption markdown="block">
Placement of train stops in Belgium, each dot represents one stop.
</figcaption>
</figure>

In this second stop generation phase,
edges are modified so that sufficiently populated areas will be included in paths formed by edges,
as illustrated by [](#generating_fig:methodology:stopsphase2).
Random edges will iteratively be selected, weighted by the edge length measured as
Euclidian distance.
(The Euclidian distance based on geographical coordinates is always used to calculate distances in this work.)
On each edge, a random cell is selected weighed by the population value in the cell.
Next, a weighed random point in a certain area around this point is selected.
This selected point is marked as a stop, the original edge is removed and two new edges are added,
marking the path between the two original edge nodes and the newly selected node.

<figure id="generating_fig:methodology:stopsphase2">

<figure id="generating_fig:methodology:stopsphase2_1" class="subfigure">
<img src="generating/img/stops_phase2_1.svg" alt="Real stops" class="figure-small">
<figcaption markdown="block">
Selecting a weighted random point on the edge.
</figcaption>
</figure>

<figure id="generating_fig:methodology:stopsphase2_2" class="subfigure">
<img src="generating/img/stops_phase2_2.svg" alt="Generation phase step 1" class="figure-small">
<figcaption markdown="block">
Defining an area around the selected point.
</figcaption>
</figure>

<figure id="generating_fig:methodology:stopsphase2_3" class="subfigure">
<img src="generating/img/stops_phase2_3.svg" alt="Generation phase step 2" class="figure-small">
<figcaption markdown="block">
Choosing a random point within the area, weighted by population value.
</figcaption>
</figure>

<figure id="generating_fig:methodology:stopplacementp2" class="subfigure">
<img src="generating/img/stops_phase2_4.svg" alt="Generation phase step 2" class="figure-small">
<figcaption markdown="block">
Modify edges so that the path includes this new point.
</figcaption>
</figure>

<figcaption markdown="block">
Illustration of the second phase of stop generation where edges are modified to include sufficiently populated areas in paths.
</figcaption>
</figure>

#### Edges
The next phase in public transit network generation connects stops that were generated in the previous phase with edges.
In order to simulate real transit network structures, we split up this generation phase into three sequential steps.
In the first step, clusters of nearby stops are formed, to lay the foundation for short-distance routes.
Next, these local clusters are connected with each other, to be able to form long-distance routes.
Finally, a cleanup step is in place to avoid abnormal edge structures in the network.

**Short-distance**
The formation of clusters with nearby stations is done using agglomerative hierarchical clustering.
Initially, each stop is part of a seperate cluster, where each cluster always maintains its centroid.
The clustering step will iteratively try to merge two clusters with their centroid distance below a certain threshold.
This threshold will increase for each iteration, until a maximum value is reached.
The maximum distance value indicates the maximum inter-stop distance for forming local clusters.
When merging two clusters, an edge is added between the closest stations from the respective clusters.
The center location of the new cluster is also recalculated before the next iteration.

**Long-distance**
At this stage, we have several clusters of nearby stops.
Because all stops need to be reachable from all stops, these separate clusters also need to be connected.
This problem is related to the domain of route planning over public transit networks,
in which networks can be decomposed into smaller clusters of nearby stations to improve the efficiency of route planning.
Each cluster contains one or more [*border stations*](cite:cites scalabletransferpatterns), which are the only points
through which routes can be formed between different clusters.
We reuse this concept of border stations, by iteratively picking a random cluster,
identifying its closest cluster based on the minimal possible stop distance, and connecting their border stations using a new edge.
After that, the two clusters are merged.
The iteration will halt when all clusters are merged and there is only one connected graph.

**Cleanup**
The final cleanup step will make sure that the number of stops that are connected by only one edge are reduced.
In real train networks, the majority of stations are connected with at least more than one other station.
The two earlier generation steps however generate a significant number of *loose stops*,
which are connected with only a single other stop with a direct edge.
In this step, these loose stops are identified, and an attempt is made to connect them to other nearby stops as shown in [](#generating_alg:methodology:loosestops).
For each loose stop, this is done by first identifying the direction of the single edge of the loose stop on line 18.
This direction is scaled by the radius in which to look for stops, and defines the stepsize for the loop that starts on line 20.
This loop starts from the loose stop and iteratively moves the search position in the defined direction, until it finds a random stop in the radius,
or the search distance exceeds the average distance between the stops in the neighbourhood of this loose stop.
This random stop from line 22 can be determined
by finding all stations that have a distance to the search point that is below the radius, and picking a random stop from this collection.
If such a stop is found, an edge is added from our loose stop to this stop.

<figure id="generating_alg:methodology:loosestops" class="algorithm numbered">
````/generating/code/algo_loosestops.txt````
<figcaption markdown="block">
Reduce the number of loose stops by adding additional edges.
</figcaption>
</figure>

[](#generating_fig:methodology:edges) shows an example of these three steps.
After this phase, a network with stops and edges is available, and the actual transit planning can commence.

<figure id="generating_fig:methodology:edges">
 
<figure id="generating_fig:methodology:edges1" class="subfigure">
<img src="generating/img/edges_1.svg" alt="Real stops" class="figure-small">
<figcaption markdown="block">
Formation of local clusters.
</figcaption>
</figure>

<figure id="generating_fig:methodology:edges2" class="subfigure">
<img src="generating/img/edges_2.svg" alt="Generation phase step 1" class="figure-small">
<figcaption markdown="block">
Connecting clusters through border stations.
</figcaption>
</figure>

<figure id="generating_fig:methodology:edges3" class="subfigure">
<img src="generating/img/edges_3.svg" alt="Generation phase step 2" class="figure-small">
<figcaption markdown="block">
Cleanup of loose stops.
</figcaption>
</figure>

<figcaption markdown="block">
Example of the different steps in the edges generation algorithm.
</figcaption>
</figure>

**Generator Objectives**
The main guaranteed objective of the edge generator is that the stops form a single connected transit network graph.
This is to ensure that all stops in the network can be reached from any other stop using at least one path through the network.

#### Routes

Given a network of stops and edges, this phase generates routes over the network.
This is done by creating short and long distance routes in two sequential steps.

**Short-distance**
The goal of the first step is to create short routes where vehicles deliver each passed stop.
This step makes sure that all edges are used in at least one route,
this ensures that each stop can at least be reached from each other stop with one or more transfers to another line.
The algorithm does this by first determining a subset of the largest stops in the network, based on the population value.
The shortest path from each large stop to each other large stop through the network is determined.
if this shortest path is shorter than a predetermined value in terms of the number of edges,
then this path is stored as a route, in which all passed stops are considered as actual stops in the route.
For each edge that has not yet been passed after this, a route is created by iteratively
adding unpassed edges to the route that are connected to the edge until an edge is found that has already been passed.

**Long-distance**
In the next step, longer routes are created, where the transport vehicle not necessarily halts at each passed stop.
This is done by iteratively picking two stops from the list of largest stops using the [network-based method](cite:cites generatingnetworkbasedmovingobjects) with each stop having an equal chance to be selected.
A heuristical shortest path algorithm is used to determine a route between these stops.
This algorithm searches for edges in the geographical direction of the target stop.
This is done to limit the complexity of finding long paths through potentially large networks.
A random amount of the largest stops on the path are selected, where the amount
is a value between a minimum and maximum preconfigured route length.
This iteration ends when a predetermined number of routes are generated.

**Generator Objectives**
This algorithm takes into account the [objectives of route design](cite:cites transitnetworkdesignscheduling), as discussed in [](#generating_related-work).
More specifically, by first focusing on the largest stops, a minimal level of *area coverage* and *demand satisfaction* is achieved,
because the largest stops correspond to highly populated areas, which therefore satisfies at least a large part of the population.
By determining the shortest path between these largest stops, the *route and trip directness* between these stops is optimal.
Finally, by not instantiating all possible routes over the network, the *total route length* is limited to a reasonable level.

#### Trips
{:#generating_subsec-methodology-trips}

A time-agnostic transit network with routes has been generated in the previous steps.
In this final phase, we temporally instantiate routes
by first determining starting times for trips,
after which the following stop times can be calculated based on route distances.
Instead of generating explicit timetables, as is done in typical transit scheduling methodologies,
we create fictional rides of vehicles.
In order to achieve realistic trip times, we approximate real trip time distributions,
with the possibility to encounter delays.

As mentioned before in [](#generating_related-work), each consecutive pair of start and stop time in a trip over an edge corresponds to a connection.
A connection can therefore be represented as a pair of timestamps,
a link to the edge representing the departure and arrival stop,
a link to the trip it is part of,
and its index within this trip.

**Trip Starting Times**
The trips generator iteratively creates new connections until a predefined number is reached.
For each connection, a random route is selected with a larger chance of picking a long route.
Next, a random start time of the connection is determined.
This is done by first picking a random day within a certain range.
After that, a random hour of the day is determined using a preconfigured distribution.
This distribution is derived from the public logs of [iRail](https://hello.irail.be){:.mandatory},
a [route planning API in Belgium](cite:cites transitapilogs).
A seperate hourly distribution is used for weekdays and weekends, which is chosen depending on the random day that was determined.

**Stop Times**
Once the route and the starting time have been determined, different stop times across the trip can be calculated.
For this, we take into account the following factors:

* Maximum vehicle speed $$\omega$$, preconfigured constant.
* Vehicle acceleration $$\varsigma$$, preconfigured constant.
* Connection distance $$\delta$$, Euclidian distance between stops in network.
* Stop size $$\sigma$$, derived from population value.

For each connection in the trip, the time it takes for a vehicle to move between the two stops over a certain distance is calculated
using the formula in [](#generating_math:methodology:distanceduration).
[](#generating_math:methodology:timetomaxspeed) calculates the required time to reach maximum speed
and [](#generating_math:methodology:distancetomaxspeed) calculates the required distance to reach maximum speed.
This formula simulates the vehicle speeding up until its maximum speed, and slowing down again until it reaches its destination.
When the distance is too short, the vehicle will not reach its maximum speed,
and just speeds up as long as possible until is has to slow down again to stop in time.

<figure id="generating_math:methodology:timetomaxspeed" class="equation" markdown="1">
$$
\begin{aligned}
    T_\omega &= \omega / \varsigma
\end{aligned}
$$
<figcaption markdown="block">
Time to reach maximum speed.
</figcaption>
</figure>

<figure id="generating_math:methodology:distancetomaxspeed" class="equation" markdown="1">
$$
\begin{aligned}
    \delta_\omega &= T_\omega^2 \cdot \varsigma
\end{aligned}
$$
<figcaption markdown="block">
Distance to reach maximum speed.
</figcaption>
</figure>

<figure id="generating_math:methodology:distanceduration" class="equation" markdown="1">
$$
\begin{aligned}
\begin{cases}
    2T_\omega + (\delta - 2 \delta_\omega) / \omega &\text{ if } \delta_\omega < \delta / 2 \\
    \sqrt{2\delta / \varsigma} &\text{ otherwise}
\end{cases}
\end{aligned}
$$
<figcaption markdown="block">
Duration for a vehicle to move between two stops.
</figcaption>
</figure>

Not only the connection duration, but also the waiting times of the vehicle at each stop are important for determining the stop times.
These are calculated as a constant minimum waiting time together with a waiting time that increases for larger stop sizes $$\sigma$$,
this increase is determined by a predefined growth factor.

**Delays**
Finally, each connection in the trip will have a certain chance to encounter a delay.
When a delay is applicable, a delay value is randomly chosen within a certain range.
Next to this, also a cause of the delay is determined from a preconfigured list.
These causes are based on the Traffic Element Events from the [Transport Disruption ontology](https://transportdisruption.github.io/){:.mandatory},
which contains a number of events that are not planned by the network operator such as strikes, bad weather or animal collisions.
Different types of delays can have a different impact factor of the delay value,
for instance, simple delays caused by rush hour would have a lower impact factor than a major train defect.
Delays are carried over to next connections in the trip, with again a chance of encountering additional delay.
Furthermore, these delay values can also be reduced when carried over to the next connection by a certain predetermined factor,
which simulates the attempt to reduce delays by letting vehicles drive faster.

**Generator Objectives**
For trip generation, we take into account several objectives from the
setting of frequencies and timetabling from [transit planning](cite:cites transitnetworkdesignscheduling).
By instantiating more long distance routes, we aim to increase *demand satisfaction* as much as possible,
because these routes deliver busy and populated areas, and the goal is to deliver these more frequently.
Furthermore, by taking into account realistic time distributions for trip instantiation, we also adhere to this objective.
Secondly, by ensuring waiting times at each stop that are longer for larger stations,
the *transfer coordination* objective is taken into account to some extent.
