### Public Transit Background
{:#generating_public-transit-background}

In this section, we present background on public transit planning that is essential to this work.
We discuss existing public transit network planning methodologies
and formats for exchanging transit feeds.

#### Public Transit Planning

The domain of public transit planning entails the design of public transit networks,
rostering of crews, and all the required steps inbetween.
The goal is to maximize the quality of service for passengers while minimizing the costs for the operator.
Given a public demand and a topological area, this planning process aims to obtain routes, timetables and vehicle and crew assignment.
A survey about 69 existing public transit planning approaches
shows that these processes are typically subdivided into [five sequential steps](cite:cites transitnetworkdesignscheduling):

1. **route design**, the placement of transit routes over an existing network.
2. **frequencies setting**, the temporal instantiation of routes based on the available vehicles and estimated demand.
3. **timetabling**, the calculation of arrival and departure times at each stop based on estimated demand.
4. **vehicle scheduling**, vehicle assignment to trips.
5. **crew scheduling and rostering**, the assignment of drivers and additional crew to trips.

In this paper, we only consider the first three steps for our mimicking algorithm,
which leads to all the required information
that is of importance to passengers in a public transit schedule.
We present the three steps from this survey in more detail hereafter.

The first step, route design, requires the topology of an area and public demand as input.
This topology describes the network in an area, which contains possible stops and edges between these stops.
Public demand is typically represented as *origin-destination* (OD) matrices,
which contain the number of passengers willing to go from origin stops to destination stops.
Given this input, routes are designed based on the following [objectives](cite:cites transitnetworkdesignscheduling):

* **area coverage**: The percentage of public demand that can be served.
* **route and trip directness**: A metric that indicates how much the actual trips from passengers deviate from the shortest path.
* **demand satisfaction**: How many stops are close enough to all origin and destination points.
* **total route length**: The total distance of all routes, which is typically minimized by operators.
* **operator-specific objectives**: Any other constraints the operator has, for example the shape of the network.
* **historical background**: Existing routes may influence the new design.

The next step is the setting of frequencies, which is based on the routes from the previous step, public demand and vehicle availability.
The main objectives in this step are based on the following [measures](cite:cites transitnetworkdesignscheduling):

* **demand satisfaction**: How many stops are serviced frequently enough to avoid overcrowding and long waiting times.
* **number of line runs**: How many times each line is serviced -- a trade-off between the operator's aim for minimization and the public demand for maximization.
* **waiting time bounds**: Regulation may put restrictions on minimum and maximum waiting times between line runs.
* **historical background**: Existing frequencies may influence the new design.

The last important step for this work is timetabling, which takes the output from the previous steps as input, together with the public demand.
The objectives for this step are the following:

* **demand satisfaction**: Total travel time for passengers should be minimized.
* **transfer coordination**: Transfers from one line to another at a certain stop should be taken into account during stop waiting times, including how many passengers are expected to transfer.
* **fleet size**: The total amount of available vehicles and their usage will influence the timetabling possibilities.
* **historical background**: Existing timetables may influence the new design.

#### Transit Feed Formats

The de-facto standard for public transport time schedules is
the [General Transit Feed Specification (GTFS)](https://developers.google.com/transit/gtfs/){:.mandatory}.
GTFS is an exchange format for transit feeds, using a series of CSV files contained in a zip file.
The specification uses the following terminology to define the rules for a public transit system:

* **Stop** is a geospatial location where vehicles stop and passengers can get on or off, such as platform 3 in the train station of Brussels.
* **Stop time** indicates a scheduled arrival and departure time at a certain stop.
* **Route** is a time-independent collection of stops, describing the sequence of stops a certain vehicle follows in a certain public transit line. For example the train route from Brussels to Ghent.
* **Trip** is a collection of stops with their respective stop times, such as the route from Brussels to Ghent at a certain time.

The zip file is put online by a public transit operator, to be downloaded by [route planning](cite:cites routeplanning) software.
[Two models are commonly used to then extract these rules into a graph](cite:cites pyrga2008efficient).
In a *time-expanded model*, a large graph is modeled with arrivals and departures as nodes and edges connect departures and arrivals together.
The weights on these edges are constant.
In a *time-dependent model*, a smaller graph is modeled in which vertices are physical stops and edges are transit connections between them.
The weights on these edges change as a function of time.
In both models, Dijkstra and Dijkstra-based algorithms can be used to calculate routes.

In contrast to these two models, the [*Connection Scan Algorithm*](cite:cites csa)
takes an ordered array representation of *connections* as input.
A connection is the actual departure time at a stop and an arrival at the next stop.
These connections can be given a IRI, and described using RDF, using the [Linked Connections](cite:cites linkedconnections) ontology.
For this base algorithm and its derivatives, a connection object is the smallest building block of a transit schedule.

In our work, generated public transport networks and time schedules
can be serialized to both the GTFS format, and RDF datasets using the Linked Connections ontology.
