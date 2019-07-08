### Query Engine
{:#querying-evolving_query-engine}

TPF query evaluation involves server and client software, because the client actively takes part in the
query evaluation, as opposed to traditional SPARQL endpoints where the server does all of the work.
Our solution allows users to send a normal SPARQL query to the local query engine
which autonomously detects the dynamic parts of the query and continuously sends back results
from that query to the user.
In this section, we discuss the architecture of our proposed solution and the most important
algorithms that were used to implement this.      
  
#### Architecture

Our solution must be able to handle regular SPARQL 1.1 queries,
detect the dynamic parts, and produce continuously updating results for non-high frequency queries.
To achieve this, we chose to build an extra software layer on top of the existing TPF client that
supports each discussed labeling type and annotation method and is capable of doing
dynamic query transformation and result streaming.
At the TPF server, dynamic data must be annotated with time depending on the
used combination of labeling type and method.
The server expects dynamic data to be pushed to the platform by an external process with varying data.
In the case of graph-based annotation, we have to extend the TPF server implementation,
so that it supports quads.
This dynamic data should be pushed to the platform by an external process with varying data.

<figure id="querying-evolving_fig:architecture">
<img src="querying-evolving/img/solution-architecture.svg" alt="[TPF Query Streamer architecture]">
<figcaption markdown="block">
Overview of the proposed client-server architecture.
</figcaption>
</figure>

[](#querying-evolving_fig:architecture) shows an overview of the architecture for this extra layer on top of the
TPF client, which will be called the *TPF Query Streamer* from now on.
The left-hand side shows the *User* that can send a regular SPARQL query to the TPF Query Streamer
entry-point and receives a stream of query results.
The system can execute queries through the local *Basic Graph Iterator*, which is part of
the TPF client and executes queries against a TPF&nbsp;server.

The TPF Query Streamer consists of six major components.
First, there is the *Rewriter* module which is executed only once at the start of the query streaming loop.
This module is able to transform the original input query into a *static* and a *dynamic query*
which will respectively retrieve the static background data and the time-annotated changing data.
This transformation happens by querying metadata of the triple patterns against the entry-point through
the local TPF client.
The *Streamer* module takes this dynamic query, executes it and forwards its results
to the *Time Filter*.
The *Time Filter* checks the time annotation for each of the results and rejects those that are
not valid for the current time.
The minimal expiration time of all these results is then determined and used as a delayed call to the
*Streamer* module to continue with the *streaming loop*, which is determined by the repeated
invocation of the *Streamer* module.
This minimal expiration time will make sure that when at least one of the results expire, a new set
of results will be fetched as part of the next query iteration.
The filtered dynamic results will be passed on to the *Materializer* which is responsible for
creating *materialized static queries*.
This is a transformation of the *static query* with the dynamic results filled in.
These *materialized static queries* are passed to the *Result Manager* which is able to cache
these queries.
Finally, the *Result Manager* retrieves previous *materialized static query* results from
the local cache or executes this query for the first time and stores its results in the cache.
These results are then sent to the client who had initiated continuous query.

#### Algorithms
    
**Query rewriting**
As mentioned in the previous section, the *Rewriter* module performs a preprocessing step
that can transform a regular SPARQL 1.1 query into a static and dynamic query.
A first step in this transformation is to detect which triple patterns inside the original query
refer to static triples and which refer to dynamic triples.
We detect this by making a separate query for each of the triple patterns and transforming each of them
to a dynamic query.
An example of such a transformation can be found in [](#query-evolving_listing:example:dynamic).
We then evaluate each of these transformed queries and assume a triple pattern is
*dynamic* if its corresponding query has at least one result.
Another step before the actual query splitting is the conversion of blank nodes to variables.
We will end up with one static query and one dynamic query,
in case these graphs were originally connected, they still need to be connected after the query splitting.
This connection is only possible with variables that are visible,
meaning that these variables need to be part of the `SELECT` clause.
However, a variable can also be anonymous and not visible: these are blank nodes.
To make sure that we take into account blank nodes that connect the static and dynamic graph,
these nodes have to be converted to variables, while maintaining their semantics.
After this step, we iterate over each
triple pattern of the original query and assign them to either the static or the dynamic query
depending on whether or not the pattern is respectively static or dynamic.
This assignment must maintain the hierarchical structure of the original query,
in some cases this causes triple patterns to be present in the dynamic query when using complex operators
like \union to maintain correct query semantics.
An example of this query transformation for our basic query from [](#query-evolving_listing:usecase:basicquery)
can be found in [](#query-evolving_listing:usecase:staticquery) and [](#query-evolving_listing:usecase:dynamicquery).

<figure id="querying-evolving_listing:example:dynamic" class="listing">
````/querying-evolving/code/example-timesensitive.sparql````
<figcaption markdown="block">
Dynamic SPARQL query for the triple pattern `?s ?p ?o` for graph-based annotation with expiration times.
</figcaption>
</figure>

<figure id="querying-evolving_listing:usecase:dynamicquery" class="listing">
````/querying-evolving/code/usecase-staticquery.sparql````
<figcaption markdown="block">
Static SPARQL query which has been derived from the basic SPARQL query from [](#querying-evolving_listing:usecase:basicquery) by the *Rewriter* module.
</figcaption>
</figure>

<figure id="querying-evolving_listing:ta:originaltriples" class="listing">
````/querying-evolving/code/usecase-dynamicquery.sparql````
<figcaption markdown="block">
Dynamic SPARQL query which has been derived from the basic SPARQL query from [](#querying-evolving_listing:usecase:basicquery) by the *Rewriter* module. Graph-based annotation is used with expiration times.
</figcaption>
</figure>

**Query materialization**
The *Materializer* module is responsible for creating *materialized static queries*
from the static query and the current dynamic query results.
This is done by filling in each dynamic result into the static query variables.
It is possible that multiple results are returned from the dynamic query evaluation, which
is the same amount of materialized static queries that can be derived.
Assuming that we, for example, find the following single dynamic query result from the dynamic query in
[](#query-evolving_listing:usecase:dynamicquery):
$$\{ \texttt{?id} \mapsto \texttt{<http://example.org/train\#train4815>},
    \texttt{?delay} \mapsto \texttt{"P10S"\^{}\^{}xsd:duration}
\}$$
then we can derive the materialized static query by filling in these two variables into the static query from
[](#query-evolving_listing:usecase:staticquery), the resulting query can be found in 
[](#query-evolving_listing:usecase:materializedstaticquery).

<figure id="querying-evolving_listing:usecase:materializedstaticquery" class="listing">
````/querying-evolving/code/usecase-materializedstaticquery.sparql````
<figcaption markdown="block">
Materialized static SPARQL query derived by filling in the dynamic query results into the static query from [](#querying-evolving_listing:usecase:materializedstaticquery).
</figcaption>
</figure>

**Caching**
The *Result manager* is the last step in the streaming loop for returning the materialized
static query results of one time instance.
This module is responsible for either getting results for given queries from its cache,
or fetching the results from the TPF client.
First, an identifier will be determined for each materialized static query.
This identifier will serve as a key to cache static data and should correctly
and uniquely identify static results based on dynamic results.
This is equivalent to saying that this identifier should be the *connection*
between the static and dynamic graphs.
This connection is the intersection of the variables present in the \where clause of the
static and dynamic queries.
Since the dynamic query results are already available at this point, these variables
all have values, so this cache identifier can be represented by these variable results.
The graph connection between the static and dynamic queries from [](#query-evolving_listing:usecase:staticquery) and [](#query-evolving_listing:usecase:dynamicquery) is `?id`.
The cache identifier for a result where `?id` is `"train:4815"` is for example `"?id=train:4815"`.
