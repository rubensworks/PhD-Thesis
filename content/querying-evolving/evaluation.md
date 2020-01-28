### Evaluation
{:#querying-evolving_evaluation}

In order to validate our hypotheses from [](#querying-evolving_problem-statement), we set up an experiment to measure the
impact of our proposed redistribution of workload between the client and server by simultaneously executing
a set of queries against a server using our proposed solution.
We repeat this experiment for two
state-of-the-art solutions: C-SPARQL and CQELS.

To test the client and server performance, our experiment consisted of one server and ten physical clients.
Each of these clients can execute from one to twenty unique concurrent queries
based on the use case from [](#querying-evolving_use-case).
The data for this experiment was derived from real-world Belgian railway data
using the [iRail API](https://hello.irail.be/api/1-0/){:.mandatory}.
This results in a series of 10 to 200 concurrent query executions.
This setup was used to test the client and server performance of different SPARQL streaming approaches.

For comparing the efficiency of different time annotation methods
and for measuring the effectiveness of our client-side cache,
we measured the execution times of the query for our use case from [](#querying-evolving_use-case).
This measurement was done for different annotation methods, once with the cache and once without the cache.
For discovering the evolution of the query evaluation efficiency through time,
the measurements were done over each query stream iteration of the query.

The discussed architecture was [implemented in JavaScript using Node.js](https://github.com/LinkedDataFragments/QueryStreamer.js/tree/eswc2016){:.mandatory} to
allow for easy communication with the existing TPF client.

The [tests](https://github.com/rubensworks/TPFStreamingQueryExecutor-experiments/){:.mandatory} were executed on the
[Virtual Wall (generation 2) environment from imec](cite:cites virtualwall).
Each machine had two Hexacore Intel E5645 (2.4GHz) CPUs with 24 GB RAM and was running Ubuntu 12.04 LTS.
For CQELS, we used [version 1.0.1 of the engine](cite:cites cqelsengine). For C-SPARQL, this was [version 0.9](cite:cites csparqlengine).
The dataset for this use case consisted of about 300 static triples, and around
200 dynamic triples that were created and removed each ten seconds.
Even this relatively small dataset size already reveals important differences
in server and client cost, as we will discuss in the paragraphs below.

#### Server Cost
{:#querying-evolving_subsec:Results-ServerCost}
    
The server performance results from our main experiment can be seen in [](#querying-evolving_fig:res:scalability-server).
On the one hand, this plot shows an increasing CPU usage for C-SPARQL and CQELS for higher numbers of concurrent query executions.
On the other hand, our solution never reaches more than one percent of server CPU usage.
[](#querying-evolving_fig:res:scalability-server-200) shows a detailed view on the measurements in the case of 200 simultaneous
query executions: the CPU peaks for the alternative approaches are much higher and more frequent than for our solution.

<div class="printonly empty-page">&nbsp;</div>

#### Client Cost
{:#querying-evolving_subsec:Results-ClientCost}
    
The results for the average CPU usage across the duration of the query evaluation
of all clients that sent queries to the server in our main experiment can be seen
in [](#querying-evolving_fig:res:scalability-client) and [](#querying-evolving_fig:res:scalability-client-all).
The clients that were sending C-SPARQL and CQELS queries to the server had a client
CPU usage of nearly zero percent for the whole duration of the query evaluation.
The clients using the client-side TPF Query Streamer solution that was presented in this work
had an initial CPU peak reaching about 80%, which dropped to about
5% after 4 seconds.

#### Annotation Methods
{:#querying-evolving_subsec:Results-AnnotationMethods}
    
The execution times for the different annotation methods, once with and once without cache can be seen in [](#querying-evolving_fig:res:overview).
The three annotation methods have about the same relative performance in all figures, but the execution
times are generally lower in the case where the client-side cache was used, except for the first
query iteration.
The execution times for expiration time annotation when no cache is used are constant,
while the execution times with caching slightly decrease over time.

<figure id="querying-evolving_fig:res:scalability">

<figure id="querying-evolving_fig:res:scalability-server" class="subfigure">
<center><strong>Server load</strong></center>
<img src="querying-evolving/img/scalability.png">
<figcaption markdown="block">
The server&nbsp;CPU usage of our solution proves to be influenced less by the number of clients.
</figcaption>
</figure>

<figure id="querying-evolving_fig:res:scalability-client" class="subfigure">
<center><strong>Client load</strong></center>
<img src="querying-evolving/img/scalability-client.png">
<figcaption markdown="block">
In the case of 200&nbsp;concurrent clients,
client CPU usage initially is high after which it converges to about 5%.
The usage for C-SPARQL and CQELS is almost non-existing.
</figcaption>
</figure>

<figcaption markdown="block">
Average server and client CPU usage for one query stream for C-SPARQL, CQELS and the proposed solution.
Our solution effectively moves complexity from the server to the client.
</figcaption>
</figure>

<figure id="querying-evolving_fig:res:boxplots">

<figure id="querying-evolving_fig:res:scalability-server-200" class="subfigure">
<center><strong>Server load</strong></center>
<img src="querying-evolving/img/scalabilityBoxplot-200.png">
<figcaption markdown="block">
Server CPU peaks for C-SPARQL and CQELS compared to our solution.
</figcaption>
</figure>

<figure id="querying-evolving_fig:res:scalability-client-all" class="subfigure">
<center><strong>Client load</strong></center>
<img src="querying-evolving/img/clientScalabilityBoxplot.png">
<figcaption markdown="block">
Client CPU usage for our solution is significantly higher.
</figcaption>
</figure>

<figcaption markdown="block">
Detailed view on all server and client CPU measurements for C-SPARQL, CQELS and the solution presented in this work for 200 simultaneous query evaluations against the server.
</figcaption>
</figure>

<figure id="querying-evolving_fig:res:overview">

<figure id="querying-evolving_fig:res:ItCf" class="subfigure">
<img src="querying-evolving/img/interval-true_caching-false.png">
<figcaption markdown="block">
Time intervals without caching.
</figcaption>
</figure>

<figure id="querying-evolving_fig:res:ItCt" class="subfigure">
<img src="querying-evolving/img/interval-true_caching-true.png">
<figcaption markdown="block">
Time intervals with caching.
</figcaption>
</figure>

<figure id="querying-evolving_fig:res:IfCf" class="subfigure">
<img src="querying-evolving/img/interval-false_caching-false.png">
<figcaption markdown="block">
Expiration times without caching.
</figcaption>
</figure>

<figure id="querying-evolving_fig:res:IfCt" class="subfigure">
<img src="querying-evolving/img/interval-false_caching-true.png">
<figcaption markdown="block">
Expiration times with caching.
</figcaption>
</figure>

<figcaption markdown="block">
Executions times for the three different types of dynamic data representation for several subsequent streaming requests.
The figures show a mostly linear increase when using time intervals and constant execution times for annotation using expiration times.
In general, caching results in lower execution times.
They also reveal that the graph approach has the lowest execution times.
</figcaption>
</figure>
