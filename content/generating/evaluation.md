### Evaluation
{:#generating_evaluation}

In this section, we discuss our evaluation of PoDiGG.
We first evaluate the realism of the generated datasets using a constant seed by comparing its coherence to real datasets,
followed by a more detailed realism evaluation of each sub-generator using distance functions.
Finally, we provide an indicative efficiency and scalability evaluation of the generator and discuss practical dataset sizes.
All scripts that were used for the following evaluation can be found on [GitHub](https://github.com/PoDiGG/podigg-evaluate){:.mandatory}.
Our experiments were executed on a 64-bit Ubuntu 14.04 machine with 128 GB of memory and a 24-core 2.40 GHz CPU.

#### Coherence
{:#generating_subsec:evaluation:coherence}

##### Metric
In order to determine how closely synthetic RDF datasets resemble their real-world variants in terms of *structuredness*,
the [coherence metric](cite:cites rdfbenchmarksdatasets) can be used.
In RDF dataset generation, the goal is to reach a level of structuredness similar to real datasets.
As mentioned before in [](#generating_related-work), many synthetic datasets have a level of structuredness that is higher than their real-world counterparts.
Therefore, our coherence evaluation should indicate that our generator is not subject to the same problem.
We have implemented a [command-line tool](https://github.com/PoDiGG/graph-coherence){:.mandatory}
to calculate the coherence value for any given input dataset.
    
##### Results
When measuring the coherence of the Belgian railway, buses and Dutch railway datasets,
we discover high values for both the real-world datasets and the synthetic datasets, as can be seen in [](#generating_table:eval:coherence).
These nearly maximal values indicate that there is a very high level of structuredness in these real-world datasets.
Most instances have all the possible values, unlike most typical RDF datasets,
[which have values around or below 0.6](cite:cites rdfbenchmarksdatasets).
That is because of the very specialized nature of this dataset, and the fact that they originate
from GTFS datasets that have the characteristics of relational databases.
Only a very limited number of classes and predicates are used,
where almost all instances have the same set of attributes.
In fact, these very high coherence values for real-world datasets simplify the process of synthetic dataset generation,
as less attention needs to be given to factors that lead to lower levels of structuredness, such as optional attributes for instances.
When generating synthetic datasets using PoDiGG with the same number of stops, routes and connections for the three gold standards,
we measure very similar coherence values, with differences ranging from 0.08% to 1.64%.
This confirms that PoDiGG is able to create datasets with the same high level of structuredness to real datasets of these types,
as it inherits the relational database characteristics from its GTFS-centric mimicking algorithm.

<figure id="generating_table:eval:coherence" class="table" markdown="1">
    
|                | Belgian railway | Belgian buses | Dutch railway |
|:---------------|----------------:|--------------:|--------------:|
| **Real**       | 0.9845          | 0.9969        | 0.9862        |
| **Synthetic**  | 0.9879          | 0.9805        | 0.9870        |
| **Difference** | 0.0034          | 0.0164        | 0.0008        |

<figcaption markdown="1">
Coherence values for three gold standards compared to the values for equivalent synthetic variants.
</figcaption>
</figure>

#### Distance to Gold Standards
{:#generating_subsec:evaluation:distance}

While the coherence metric is useful to compare the level of structuredness between datasets,
it does not give any detailed information about how *real* synthetic datasets are in terms of their *distance* to the real datasets.
In this case, we are working with public transit feeds with a known structure,
so we can look at the different datasets aspects in more detail.
More specifically, we start from real geographical areas with their population distributions,
and consider the distance functions between stops, edges, routes and trips for the synthetic and gold standard datasets.
In order to check the applicability of PoDiGG to different transport types and geographical areas,
we compare with the gold standard data of the Belgian railway, the Belgian buses and the Dutch railway.
The scripts that were used to derive these gold standards from real-world data
can be found on [GitHub](https://github.com/PoDiGG/population-density-generator){:.mandatory}.

In order to construct distance functions for the different generator elements, we consider several helper functions.
The function in [](#generating_math:eval:closest) is used to determine the closest element
in a set of elements $$B$$ to a given element $$a$$, given a distance function $$f$$.
The function in [](#generating_math:eval:distance) calculates the distance between all elements in $$A$$ and all elements in $$B$$,
given a distance function $$f$$.
The computational complexity of $$\chi$$ is $$O(|B| \cdot \kappa(f))$$,
where $$\kappa(f)$$ is the cost for one distance calculation for $$f$$.
The complexity of $$\Delta$$ then becomes $$O(|A| \cdot |B| \cdot \kappa(f))$$.

<figure id="generating_math:eval:closest" class="equation" markdown="1">
$$
\begin{aligned}
\chi(a, B, f) \coloneqq \text{arg min}_{b \in B} f(a, b)
\end{aligned}
$$
<figcaption markdown="block">
Function to determine the closest element in a set of elements.
</figcaption>
</figure>

<figure id="generating_math:eval:distance" class="equation" markdown="1">
$$
\begin{aligned}
\Delta(A, B, f) \coloneqq \\
\dfrac{
      \sum\limits_{a \in A}{f(a, \chi(a, B, f))}
    + \sum\limits_{b \in B}{f(b, \chi(b, A, f))}
    }{(|A| + |B|) * \text{arg max}_{a \in A, b \in B} f(a, b)}
\end{aligned}
$$
<figcaption markdown="block">
Function to calculate the distance between all elements in a set of elements.
</figcaption>
</figure>

##### Stops Distance
For measuring the distance between two sets of stops $$S_1$$ and $$S_2$$,
we introduce the distance function from [](#generating_math:stops:distance).
This measures the distance between every possible pair of stops using the Euclidean distance function $$d$$.
Assuming a constant execution time for $$\kappa(d)$$,
the computational complexity for $$\Delta_\text{s}$$ is $$O(|S_1| \cdot |S_2|)$$.

<figure id="generating_math:stops:distance" class="equation" markdown="1">
$$
\begin{aligned}
    \Delta_\text{s}(S_1, S_2) \coloneqq \Delta(S_1, S_2, d)
\end{aligned}
$$
<figcaption markdown="block">
Function to calculate the distance between two sets of stops.
</figcaption>
</figure>

##### Edges Distance
In order to measure the distance between two sets of edges $$E_1$$ and $$E_2$$,
we use the distance function from [](#generating_math:eval:edges:distance),
which measures the distance between all pairs of edges using the distance function $$d_\text{e}$$.
This distance function $$d_\text{e}$$, which is introduced in [](#generating_math:eval:edge:distance),
measures the Euclidean distance between the start and endpoints of each edge, and between the different edges,
weighed by the length of the edges.
The constant $$1$$ in [](#generating_math:eval:edge:distance) is to ensure that the distance between two edges that have an equal length,
but exist at a different position, is not necessarily zero.
The computational cost of $$d_\text{e}$$ can be considered as a constant,
so the complexity of $$\Delta_\text{e}$$ becomes $$O(|E_1| \cdot |E_2|)$$.

<figure id="generating_math:eval:edges:distance" class="equation" markdown="1">
$$
\begin{aligned}
\Delta_\text{e}(E_1, E_2) \coloneqq \Delta(E_1, E_2, d_\text{e})
\end{aligned}
$$
<figcaption markdown="block">
Function to calculate the distance between two sets of edges.
</figcaption>
</figure>

<figure id="generating_math:eval:edge:distance" class="equation" markdown="1">
$$
\begin{aligned}
    d_\text{e}(e_1, e_2) \coloneqq & \text{min}\big(
          d(e_1^\text{from}, e_2^\text{from})
        + d(e_1^\text{to}, e_2^\text{to}), \\
    &\quad\quad
          d(e_1^\text{from}, e_2^\text{to})
        + d(e_1^\text{to}, e_2^\text{from})\big) \\
    &\cdot (d(e_1^\text{from}, e_1^\text{to}) - d(e_2^\text{from}, e_2^\text{to}) + 1)
\end{aligned}
$$
<figcaption markdown="block">
Function to calculate the distance between two edges.
</figcaption>
</figure>

<div class="printonly empty-page">&nbsp;</div>

##### Routes Distance
Similarly, the distance between two sets of routes $$R_1$$ and $$R_2$$ is measured in [](#generating_math:eval:routes:distance)
by applying $$\Delta$$ for the distance function $$d_\text{r}$$.
[](#generating_math:eval:route:distance) introduces this distance function $$d_\text{r}$$ between two routes,
which is calculated by considering the edges in each route and measuring the distance
between those two sets using the distance function $$\Delta_\text{e}$$ from [](#generating_math:eval:edges:distance).
By considering the maximum amount of edges per route as $$e_\text{max}$$,
the complexity of $$d_\text{r}$$ becomes $$O(e_\text{max}^2)$$
This leads to a complexity of $$O(|R_1| \cdot |R_2| \cdot e_\text{max}^2)$$ for $$\Delta_\text{r}$$.

<figure id="generating_math:eval:routes:distance" class="equation" markdown="1">
$$
\begin{aligned}
\Delta_\text{r}(R_1, R_2) \coloneqq \Delta(R_1, R_2, d_\text{r})
\end{aligned}
$$
<figcaption markdown="block">
Function to calculate the distance between two sets of routes.
</figcaption>
</figure>

<figure id="generating_math:eval:route:distance" class="equation" markdown="1">
$$
\begin{aligned}
d_\text{r}(r_1, r_2) \coloneqq \Delta_\text{e}(r_1^\text{edges}, r_2^\text{edges})
\end{aligned}
$$
<figcaption markdown="block">
Function to calculate the distance between two routes.
</figcaption>
</figure>

##### Connections Distance
Finally, we measure the distance between two sets of connections $$C_1$$ and $$C_2$$
using the function from [](#generating_math:eval:connections:distance).
The distance between two connections is measured using the function from [](#generating_math:eval:connection:distance),
which is done by considering their respective temporal distance weighed by a constant $$d_\epsilon$$ --when serializing time in milliseconds, we set $$d_\epsilon$$ to $$60000$$--,
and their geospatial distance using the edge distance function $$d_\text{e}$$.
The complexity of time calculation in $$d_\text{c}$$ can be considered being constant,
which makes it overall complexity $$O(e_\text{max}^2)$$.
For $$\Delta_\text{c}$$, this leads to a complexity of $$O(|C_1| \cdot |C_2| \cdot e_\text{max}^2)$$.

<figure id="generating_math:eval:connections:distance" class="equation" markdown="1">
$$
\begin{aligned}
\Delta_\text{c}(C_1, C_2) \coloneqq \Delta(C_1, C_2, d_\text{c})
\end{aligned}
$$
<figcaption markdown="block">
Function to calculate the distance between two sets of connections.
</figcaption>
</figure>

<figure id="generating_math:eval:connection:distance" class="equation" markdown="1">
$$
\begin{aligned}
    d_\text{c}(c_1, c_2) &\coloneqq ((c_1^\text{departureTime} - c_2^\text{departureTime}) \\
    &+ (c_1^\text{arrivalTime} - c_2^\text{arrivalTime}) / d_\epsilon) \\
    &+ d_\text{e}(c_1, c_2)
\end{aligned}
$$
<figcaption markdown="block">
Function to calculate the distance between two connections.
</figcaption>
</figure>

##### Computability
When using the introduced functions for calculating the distance between stops, edges, routes or connections,
execution times can become long for a large number of elements because of their large complexity.
When applying these distance functions for realistic numbers of stops, edges, routes and connections,
several optimizations should be done in order to calculate these distances in a reasonable time.
A major contributor for these high complexities is $$\chi$$ for finding the closest element from a set of elements to a given element,
as introduced in [](#generating_math:eval:closest).
In practice, we only observed extreme execution times for the respective distance between routes and connections.
For routes, we implemented an optimization, with the same worst-case complexity,
that indexes routes based on their geospatial position, and performs radial search around each route
when the closest one from a set of other routes should be found.
For connections, we consider the linear time dimension when performing binary search for finding the closest connection within a set of elements.

##### Metrics
In order to measure the realism of each generator phase, we introduce a *realism* factor $$\rho$$ for each phase.
These values are calculated by measuring the distance from randomly generated elements to the gold standard,
divided by the distance from the actually generated elements to the gold standard,
as shown below for respectively stops, edges, routes and connections.
We consider these randomly generated elements having the lowest possible level of realism,
so we use these as a weighting factor in our realism values.

$$
\begin{aligned}
    \rho_\text{s}(S_\text{rand}, S_\text{gen}, S_\text{gs})
    &\coloneqq \Delta_\text{s}(S_\text{rand}, S_\text{gs}) / \Delta_\text{s}(S_\text{gen}, S_\text{gs})\\
    \rho_\text{e}(E_\text{rand}, E_\text{gen}, E_\text{gs})
    &\coloneqq \Delta_\text{e}(E_\text{rand}, E_\text{gs}) / \Delta_\text{e}(E_\text{gen}, E_\text{gs})\\
    \rho_\text{r}(R_\text{rand}, R_\text{gen}, R_\text{gs})
    &\coloneqq \Delta_\text{r}(R_\text{rand}, R_\text{gs}) / \Delta_\text{r}(R_\text{gen}, R_\text{gs})\\
    \rho_\text{c}(C_\text{rand}, C_\text{gen}, C_\text{gs})
    &\coloneqq \Delta_\text{c}(C_\text{rand}, C_\text{gs}) / \Delta_\text{c}(C_\text{gen}, C_\text{gs})
\end{aligned}
$$

##### Results
We measured these realism values with gold standards for the Belgian railway, the Belgian buses and the Dutch railway.
In each case, we used an optimal set of [parameters](https://github.com/PoDiGG/podigg-evaluate/blob/master/bin/evaluate.js){:.mandatory}
to achieve the most realistic generated output.
[](#generating_table:eval:realism) shows the realism values for the three cases,
which are visualized in [](#generating_fig:realism:stops), [](#generating_fig:realism:edges), [](#generating_fig:realism:routes) and [](#generating_fig:realism:connections).
Each value is larger than 1, showing that the generator at least produces data that is closer to the gold standard,
and is therefore more realistic.
The realism for edges is in each case very large, showing that our algorithm produces edges that are very similar to
actual the edge placement in public transport networks according to our distance function.
Next, the realism of stops is lower, but still sufficiently high to consider it as realistic.
Finally, the values for routes and connections show that these sub-generators produce output that is closer
to the gold standard than the random function according to our distance function.
Routes achieve the best level of realism for the Belgian railway case.
For this same case, the connections are however only slightly closer to the gold standard than random placement,
while for the other cases the realism is more significant.
All of these realism values show that PoDiGG is able to produce realistic data for different regions and different transport types.

<figure id="generating_table:eval:realism" class="table" markdown="1">
    
|                 | Belgian railway | Belgian buses | Dutch railway |
|:----------------|----------------:|--------------:|--------------:|
| **Stops**       | 5.5490          | 297.0888      | 4.0017        |
| **Edges**       | 147.4209        | 1633.4693     | 318.4131      |
| **Routes**      | 2.2420          | 0.0164        | 1.3095        |
| **Connections** | 1.0451          | 1.5006        | 1.3017        |

<figcaption markdown="1">
Realism values for the three gold standards in case of the different sub-generators,
respectively calculated for the stops $$\rho_\text{s}$$, edges $$\rho_\text{e}$$, routes $$\rho_\text{r}$$ and connections $$\rho_\text{c}$$.
</figcaption>
</figure>

<figure id="generating_fig:realism:stops">

<figure id="generating_fig:realism:stops:rand" class="subfigure">
<img src="generating/img/realism/train_be/stops_random.png" alt="Stops Random">
<figcaption markdown="block">
Random
</figcaption>
</figure>

<figure id="generating_fig:realism:stops:gen" class="subfigure">
<img src="generating/img/realism/train_be/stops_parameterized.png" alt="Stops Generated">
<figcaption markdown="block">
Generated
</figcaption>
</figure>

<figure id="generating_fig:realism:stops:gs" class="subfigure">
<img src="generating/img/realism/train_be/stops_gs.png" alt="Stops Gold standard">
<figcaption markdown="block">
Gold standard
</figcaption>
</figure>

<figcaption markdown="block">
Stops for the Belgian railway case.
</figcaption>
</figure>

<figure id="generating_fig:realism:edges">

<figure id="generating_fig:realism:edges:rand" class="subfigure">
<img src="generating/img/realism/train_be/edges_random.png" alt="Edges Random">
<figcaption markdown="block">
Random
</figcaption>
</figure>

<figure id="generating_fig:realism:edges:gen" class="subfigure">
<img src="generating/img/realism/train_be/edges_parameterized.png" alt="Edges Generated">
<figcaption markdown="block">
Generated
</figcaption>
</figure>

<figure id="generating_fig:realism:edges:gs" class="subfigure">
<img src="generating/img/realism/train_be/edges_gs.png" alt="Edges Gold standard">
<figcaption markdown="block">
Gold standard
</figcaption>
</figure>

<figcaption markdown="block">
Edges for the Belgian railway case.
</figcaption>
</figure>

<figure id="generating_fig:realism:routes">

<figure id="generating_fig:realism:routes:rand" class="subfigure">
<img src="generating/img/realism/train_be/routes_random.png" alt="Routes Random">
<figcaption markdown="block">
Random
</figcaption>
</figure>

<figure id="generating_fig:realism:routes:gen" class="subfigure">
<img src="generating/img/realism/train_be/routes_parameterized.png" alt="Routes Generated">
<figcaption markdown="block">
Generated
</figcaption>
</figure>

<figure id="generating_fig:realism:routes:gs" class="subfigure">
<img src="generating/img/realism/train_be/routes_gs.png" alt="Routes Gold standard">
<figcaption markdown="block">
Gold standard
</figcaption>
</figure>

<figcaption markdown="block">
Routes for the Belgian railway case.
</figcaption>
</figure>

<figure id="generating_fig:realism:connections">
<img src="generating/img/realism/train_be/connections_distr.svg" alt="Hourly distribution" class="figure-medium-width">
<figcaption markdown="block">
Connections per hour for the Belgian railway case.
</figcaption>
</figure>

#### Performance
{:#generating_subsec:evaluation:performance}

##### Metrics
While performance is not the main focus of this work,
we provide an indicative performance evaluation in this section in order to discover the bottlenecks and limitations
of our current implementation that could be further investigated and resolved in future work.
We measure the impact of different parameters on the execution times of the generator.
The three main parameters for increasing the output dataset size are the number of stops, routes and connections.
Because the number of edges is implicitly derived from the number of stops in order to reach a connected network,
this can not be configured directly.
In this section, we start from a set of parameters that produces realistic output data that is similar to the Belgian railway case.
We let the value for each of these parameters increase to see the evolution of the execution times and memory usage.

##### Results
[](#generating_fig:performance:times) shows a linear increase in execution times when increasing the routes or connections.
The execution times for stops do however increase much faster, which is caused by the higher complexity of networks that are formed for many stops.
The used algorithms for producing this network graph proves to be the main bottleneck when generating large networks.
Networks with a limited size can however be generated quickly, for any number of routes and connections.
The memory usage results from [](#generating_fig:performance:mem) also show a linear increase,
but now the increase for routes and connections is higher than for the stops parameter.
These figures show that stops generation is a more CPU intensive process than routes and connections generation.
These last two are able to make better usage of the available memory for speeding up the process.

<figure id="generating_fig:performance:times">
<img src="generating/img/performance/times.svg" alt="Execution times" class="figure-medium-width">
<figcaption markdown="block">
Execution times when increasing the number of stops, routes or connections.
</figcaption>
</figure>

<figure id="generating_fig:performance:mem">
<img src="generating/img/performance/mem.svg" alt="Memory usage" class="figure-medium-width">
<figcaption markdown="block">
Memory usage when increasing the number of stops, routes or connections.
</figcaption>
</figure>

#### Dataset size

An important aspect of dataset generation is its ability to output various dataset sizes.
In PoDiGG, different options are available for tweaking these sizes.
Increasing the time range parameter within the generator increases the number of connections
while the number of stops and routes will remain the same.
When enlarging the geographical area over the same period of time, the opposite is true.
As a rule of thumb, based on the number of triples per connection, stops and routes,
the total number of generated triples per dataset is approximately $$7 \cdot \textit{\#connections} + 6 \cdot \textit{\#stops} + \textit{\#routes}$$.
For the Belgian railway case, containing 30,011 connections over a period of 9 months,
with 583 stops and 362 routes, this would theoretically result in 213,937 triples.
In practice, we reach 235,700 triples when running with these parameters, which is slightly higher because of the other triples that are not
taken into account for this simplified formula, such as the ones for trips, stations and delays.
