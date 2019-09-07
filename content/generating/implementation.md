### Implementation
{:#generating_implementation}

In this section, we discuss the implementation details of PoDiGG, based on the generator algorithm introduced in [](#generating_methodology).
PoDiGG is split up into two parts: the main PoDiGG generator, which outputs GTFS data, and PoDiGG-LC,
which depends on the main generator to output RDF data.
Serialization in RDF using existing ontologies, such as the [GTFS](http://vocab.gtfs.org/terms){:.mandatory}
and [Linked Connections ontologies](http://semweb.mmlab.be/ns/linkedconnections){:.mandatory},
allows this inherently linked data to be used within RDF data management systems,
where it can for instance be used for benchmarking purposes.
Providing output in GTFS will allow this data to be used directly within all systems
that are able to handle transit feeds, such as route planning systems.
The two generator parts will be explained hereafter, followed by a section on how the generator can be configured using various parameters.

#### PoDiGG

The main requirement of our system is the ability to generate realistic
public transport datasets using the mimicking algorithm that was introduced in [](#generating_methodology).
This means that given a population distribution of a certain region,
the system must be able to design a network of routes,
and determine timely trips over this network.

PoDiGG is implemented to achieve this goal. It is written in JavaScript using Node.js,
and is available under an open license on [GitHub](https://github.com/PoDiGG/podigg){:.mandatory}.
In order to make installation and usage more convenient,
PoDiGG is available as a Node module on the [NPM package manager](https://www.npmjs.com/package/podigg){:.mandatory}
and as a Docker image on [Docker Hub](https://hub.docker.com/r/podigg/podigg/){:.mandatory} to easily run on any platform.
Every sub-generator that was explained in [](#generating_methodology), is implemented as a separate module.
This makes PoDiGG highly modifiable and composable, because different implementations of sub-generators can easily be added and removed.
Furthermore, this flexible composition makes it possible to use real data instead of certain sub-generators.
This can be useful for instance when a certain public transport network is already available, and only the trips and connections need to be generated.

We designed PoDiGG to be highly configurable
to adjust the characteristics of the generated output across different levels,
and to define a certain *seed* parameter for producing deterministic output.

All sub-generators store generated data in-memory, using list-based data structures directly corresponding to the GTFS format.
This makes GTFS serialization a simple and efficient process.
[](#generating_table:implementation:gtfsfiles) shows the GTFS files that are generated by the different PoDiGG modules.
This table does not contain references to the region and edges generator,
because they are only used internally as prerequisites to the later steps.
All required files are created to have a valid GTFS dataset.
Next to that, the optional file for exceptional service dates is created.
Furthermore, `delays.txt` is created, which is not part of the GTFS specification.
It is an extension we provide in order to serialize delay information about each connection in a trip.
These delays are represented in a CSV file containing columns for referring to a connection in a trip,
and contains delay values in milliseconds and a certain reason per connection arrival and departure,
as shown in [](#generating_listing:example:delays).

<figure id="generating_table:implementation:gtfsfiles" class="table" markdown="1">

| File         | Generator  |
|--------------|------------|
| **`agency.txt`** | *Constant* |
| **`stops.txt`** | Stops |
| **`routes.txt`** | Routes |
| **`trips.txt`** | Trips |
| **`stop_times.txt`** | Trips |
| **`calendar.txt`** | Trips |
| `calendar_dates.txt` | Trips |
| `delays.txt` | Trips |

<figcaption markdown="block">
The GTFS files that are written by PoDiGG, with their corresponding sub-generators that are responsible for generating the required data.
The files in bold refer to files that are required by the GTFS specification.
</figcaption>
</figure>

<figure id="generating_listing:example:delays" class="listing">
````/generating/code/delays-sample.txt````
<figcaption markdown="block">
Sample of a `delays.txt` file in a GTFS dataset.
</figcaption>
</figure>

In order to easily observe the network structure in the generated datasets,
PoDiGG will always produce a figure accompanying the GTFS dataset.
[](#generating_fig:generated_example) shows an example of such a visualization.

<figure id="generating_fig:generated_example">
<img src="generating/img/generated_example.png" alt="Visualization of a generated public transport network based on Belgium's population distribution" class="figure-medium">
<figcaption markdown="block">
Visualization of a generated public transport network based on Belgium's population distribution.
Each route has a different color, and dark route colors indicate more frequent trips over them than light colors.
The population distribution is illustrated for each cell as a scale going from white (low), to red (medium) and black (high).
[Full image](https://linkedsoftwaredependencies.org/raw/podigg/gen.png){:.mandatory}
</figcaption>
</figure>

Because the generation of large datasets can take a long time depending on the used parameters,
PoDiGG has a logging mechanism, which provides continuous feedback to the user about the current status and progress of the generator.

Finally, PoDiGG provides the option to derive realistic public transit queries over the generated network,
aimed at testing the load of route planning systems.
This is done by iteratively selecting two random stops weighed by their size
and choosing a random starting time based on the same time distribution as discussed in [](#generating_subsec:methodology:trips).
This is serialized to a [JSON format](https://github.com/linkedconnections/benchmark-belgianrail#transit-schedules){:.mandatory}
that was introduced for benchmarking the [Linked Connections route planner](cite:cites linkedconnections).

#### PoDiGG-LC

PoDiGG-LC is an extension of PoDiGG, that outputs data in Turtle/RDF using the ontologies shown in [](#generating_fig:methodology:datamodel).
It is also implemented in JavaScript using Node.js, and available under an open license on [GitHub](https://github.com/PoDiGG/podigg-lc){:.mandatory}.
PoDiGG-LC is also available as a Node module on [NPM](https://www.npmjs.com/package/podigg-lc){:.mandatory}
and as a Docker image on [Docker Hub](https://hub.docker.com/r/podigg/podigg-lc/){:.mandatory}.
For this, we extended the [GTFS-LC tool](https://github.com/PoDiGG/gtfs2lc){:.mandatory} that is able
to convert GTFS datasets to RDF using the Linked Connections and GTFS ontologies.
The original tool serializes a minimal subset of the GTFS data, aimed at being used for Linked Connections route planning over connections.
Our extension also serializes trip, station and route instances, with their relevant interlinking.
Furthermore, our GTFS extension for representing delays is also supported, and is serialized
using a new [Linked Connections Delay ontology](http://semweb.datasciencelab.be/ns/linked-connections-delay/){:.mandatory} that we created.

#### Configuration

PoDiGG accepts a wide range of parameters that can be used to configure properties of the different sub-generators.
[](#generating_table:implementation:params) shows an overview of the parameters, grouped by each sub-generator.
PoDiGG and PoDiGG-LC accept these [parameters](https://github.com/PoDiGG/podigg#parameters){:.mandatory}
either in a JSON configuration file or via environment variables.
Both PoDiGG and PoDiGG-LC produce deterministic output for identical sets of parameters,
so that datasets can easily be reproduced given the configuration.
The *seed* parameter can be used to introduce pseudo-randomness into the output.

<figure id="generating_table:implementation:params" class="table">
<table>
    <tr>
        <th></th>
        <th>Name</th>
        <th>Default Value</th>
        <th>Description</th>
    </tr>

    <tr class="row-sep-above">
        <td></td>
        <td><code>seed</code></td>
        <td><code>1</code></td>
        <td>The random seed</td>
    </tr>

    <tr class="row-sep-above">
        <td rowspan="4" class="rotate">Region</td>
        <td><code>region_generator</code></td>
        <td><code>isolated</code></td>
        <td>Name of a region generator. (isolated, noisy or region)</td>
    </tr>
    <tr>
        <td><code>lat_offset</code></td>
        <td><code>0</code></td>
        <td>Value to add with all generated latitudes</td>
    </tr>
    <tr>
        <td><code>lon_offset</code></td>
        <td><code>0</code></td>
        <td>Value to add with all generated longitudes</td>
    </tr>
    <tr>
        <td><code>cells_per_latlon</code></td>
        <td><code>100</code></td>
        <td>How many cells go in 1 latitude/longitude</td>
    </tr>
    
    <tr class="row-sep-above">
        <td rowspan="9" class="rotate">Stops</td>
        <td><code>stops</code></td>
        <td><code>600</code></td>
        <td>How many stops should be generated</td>
    </tr>
    <tr>
        <td><code>min_station_size</code></td>
        <td><code>0.01</code></td>
        <td>Minimum cell population value for a stop to form</td>
    </tr>
    <tr>
        <td><code>max_station_size</code></td>
        <td><code>30</code></td>
        <td>Maximum cell population value for a stop to form</td>
    </tr>
    <tr>
        <td><code>start_stop_choice_power</code></td>
        <td><code>4</code></td>
        <td>Power for selecting large population cells as stops</td>
    </tr>
    <tr>
        <td><code>min_interstop_distance</code></td>
        <td><code>1</code></td>
        <td>Minimum distance between stops in number of cells</td>
    </tr>
    <tr>
        <td><code>factor_stops_post_edges</code></td>
        <td><code>0.66</code></td>
        <td>Factor of stops to generate after edges</td>
    </tr>
    <tr>
        <td><code>edge_choice_power</code></td>
        <td><code>2</code></td>
        <td>Power for selecting longer edges to generate stops on</td>
    </tr>
    <tr>
        <td><code>stop_around_edge_choice_power</code></td>
        <td><code>4</code></td>
        <td>Power for selecting large population cells around edges</td>
    </tr>
    <tr>
        <td><code>stop_around_edge_radius</code></td>
        <td><code>2</code></td>
        <td>Radius in number of cells around an edge to select points</td>
    </tr>
    
    <tr class="row-sep-above">
        <td rowspan="7" class="rotate">Edges</td>
        <td><code>max_intracluster_distance</code></td>
        <td><code>100</code></td>
        <td>Maximum distance between stops in one cluster</td>
    </tr>
    <tr>
        <td><code>max_intracluster_distance_growthfactor</code></td>
        <td><code>0.1</code></td>
        <td>Power for clustering with more distant stops</td>
    </tr>
    <tr>
        <td><code>post_cluster_max_intracluster_distancefactor</code></td>
        <td><code>1.5</code></td>
        <td>Power for connecting a stop with multiple stops</td>
    </tr>
    <tr>
        <td><code>loosestations_neighbourcount</code></td>
        <td><code>3</code></td>
        <td>Neighbours around a loose station that should define its area</td>
    </tr>
    <tr>
        <td><code>loosestations_max_range_factor</code></td>
        <td><code>0.3</code></td>
        <td>Maximum loose station range relative to the total region size</td>
    </tr>
    <tr>
        <td><code>loosestations_max_iterations</code></td>
        <td><code>10</code></td>
        <td>Maximum iteration number to try to connect one loose station</td>
    </tr>
    <tr>
        <td><code>loosestations_search_radius_factor</code></td>
        <td><code>0.5</code></td>
        <td>Loose station neighbourhood size factor</td>
    </tr>
    
    <tr class="row-sep-above">
        <td rowspan="5" class="rotate">Routes</td>
        <td><code>routes</code></td>
        <td><code>1000</code></td>
        <td>The number of routes to generate</td>
    </tr>
    <tr>
        <td><code>largest_stations_fraction</code></td>
        <td><code>0.05</code></td>
        <td>The fraction of stops to form routes between</td>
    </tr>
    <tr>
        <td><code>penalize_station_size_area</code></td>
        <td><code>10</code></td>
        <td>The area in which stop sizes should be penalized</td>
    </tr>
    <tr>
        <td><code>max_route_length</code></td>
        <td><code>10</code></td>
        <td>Maximum number of edges for a route in the macro-step</td>
    </tr>
    <tr>
        <td><code>min_route_length</code></td>
        <td><code>4</code></td>
        <td>Minimum number of edges for a route in the macro-step</td>
    </tr>
    
    <tr class="row-sep-above">
        <td rowspan="15" class="rotate">Connections</td>
        <td><code>time_initial</code></td>
        <td><code>0</code></td>
        <td>The initial timestamp (ms)</td>
    </tr>
    <tr>
        <td><code>time_final</code></td>
        <td><code>24 * 3600000</code></td>
        <td>The final timestamp (ms)</td>
    </tr>
    <tr>
        <td><code>connections</code></td>
        <td><code>30000</code></td>
        <td>Number of connections to generate</td>
    </tr>
    <tr>
        <td><code>stop_wait_min</code></td>
        <td><code>60000</code></td>
        <td>Minimum waiting time per stop</td>
    </tr>
    <tr>
        <td><code>stop_wait_size_factor</code></td>
        <td><code>60000</code></td>
        <td>Waiting time to add multiplied by station size</td>
    </tr>
    <tr>
        <td><code>route_choice_power</code></td>
        <td><code>2</code></td>
        <td>Power for selecting longer routes for connections</td>
    </tr>
    <tr>
        <td><code>vehicle_max_speed</code></td>
        <td><code>160</code></td>
        <td>Maximum speed of a vehicle in km/h</td>
    </tr>
    <tr>
        <td><code>vehicle_speedup</code></td>
        <td><code>1000</code></td>
        <td>Vehicle speedup in km/(h$^2$)</td>
    </tr>
    <tr>
        <td><code>hourly_weekday_distribution</code></td>
        <td><code>...<sup>1</sup></code></td>
        <td>Hourly connection chances for weekdays</td>
    </tr>
    <tr>
        <td><code>hourly_weekend_distribution</code></td>
        <td><code>...<sup>1</sup></code></td>
        <td>Hourly connection chances for weekend days</td>
    </tr>
    <tr>
        <td><code>delay_chance</code></td>
        <td><code>0</code></td>
        <td>Chance for a connection delay</td>
    </tr>
    <tr>
        <td><code>delay_max</code></td>
        <td><code>3600000</code></td>
        <td>Maximum delay</td>
    </tr>
    <tr>
        <td><code>delay_choice_power</code></td>
        <td><code>1</code></td>
        <td>Power for selecting larger delays</td>
    </tr>
    <tr>
        <td><code>delay_reasons</code></td>
        <td><code>...<sup>2</sup></code></td>
        <td>Default reasons and chances for delays</td>
    </tr>
    <tr>
        <td><code>delay_reduction_duration_fraction</code></td>
        <td><code>0.1</code></td>
        <td>Maximum part of connection duration to subtract for delays</td>
    </tr>
    
    <tr class="row-sep-above">
        <td rowspan="7" class="rotate">Queryset</td>
        <td><code>start_stop_choice_power</code></td>
        <td><code>4</code></td>
        <td>Power for selecting large starting stations</td>
    </tr>
    <tr>
        <td><code>query_count</code></td>
        <td><code>100</code></td>
        <td>The number of queries to generate</td>
    </tr>
    <tr>
        <td><code>time_initial</code></td>
        <td><code>0</code></td>
        <td>The initial timestamp</td>
    </tr>
    <tr>
        <td><code>time_final</code></td>
        <td><code>24 * 3600000</code></td>
        <td>The final timestamp</td>
    </tr>
    <tr>
        <td><code>max_time_before_departure</code></td>
        <td><code>3600000</code></td>
        <td>Minimum number of edges for a route in the macro-step</td>
    </tr>
    <tr>
        <td><code>hourly_weekday_distribution</code></td>
        <td><code>...<sup>1</sup></code></td>
        <td>Chance for each hour to have a connection on a weekday</td>
    </tr>
    <tr>
        <td><code>hourly_weekend_distribution</code></td>
        <td><code>...<sup>1</sup></code></td>
        <td>Chance for each hour to have a connection on a weekend day</td>
    </tr>
</table>
<figcaption markdown="1">
Configuration parameters for the different sub-generators. Time values are represented in milliseconds.
<sup>1</sup> Time distributions are based on [public route planning logs](cite:cites transitapilogs).
<sup>2</sup> Default delays are based on the [Transport Disruption ontology](https://transportdisruption.github.io/){:.mandatory}.
</figcaption>
</figure>