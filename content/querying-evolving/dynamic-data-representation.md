### Dynamic Data Representation
{:#querying-evolving_dynamic-data-representation}

Our solution consists of a partial redistribution of query evaluation workload from the server to the client,
which requires the client to be able to access the server data.
There needs to be a distinction between regular static data and continuously updating dynamic data in the server's
dataset.
For this, we chose to define a certain temporal range in which these dynamic facts are valid, as a consequence
the client will know when the data becomes invalid and has to fetch new data to remain up-to-date.
To capture the temporal scope of data triples, we annotate this data with time.
In this section, we discuss two different types of time labeling, and different methods to annotate this data.

<div class="printonly empty-page">&nbsp;</div>

#### Time Labeling Types
{:#query-evolving_subsec:temporaldomains}

We use interval-based labeling to indicate the *start and endpoint* of the period during which triples are valid.
Point-based labeling is used to indicate the *expiration time*.

With expiration times, we only save the latest version of a given fact in a dataset, assuming that 
the old version can be removed when a&nbsp;newer one arrives.
These expiration times provide enough information to determine when a certain fact becomes invalid in time.
We use time intervals for storing multiple versions of the same fact, i.e., for maintaining a history of facts.
These time intervals must indicate a start- and endtime for making it possible to distinguish between different versions
of a certain fact. These intervals cannot overlap in time for the same facts.
When data is volatile, consecutive interval-based facts will accumulate quickly.
Without techniques to aggregate or remove old data, datasets will quickly grow, which can cause increasingly slower query executions.
This problem does not exist with expiration times because in this approach we decided to only save the latest version of a fact, so
this volatility will not have any effect on the dataset size.

#### Methods for Time Annotation
{:#query-evolving_sec:tatypes}
        
The two time labeling types introduced in the last section can be annotated on triples in different ways.
In [](#querying-evolving_related-work_annotations) we discussed several methods for RDF annotation.
We will apply time labels to triples using the singleton properties, graphs and implicit graphs annotation techniques.

**Singleton Properties**
*Singleton properties* annotation is done by creating
a singleton property for the predicate of each dynamic triple.
Each of these singleton properties can then be annotated with its time annotation, being either
a time interval or expiration&nbsp;times.

**Graphs**
To time-annotate triples using *graphs*, we can encapsulate triples inside contexts,
and annotate each context graph with a time annotation.

**Implicit Graphs**
A&nbsp;TPF interface gives a unique IRI to each fragment corresponding to a&nbsp;triple pattern, including patterns without variables, i.e., actual triples.
Since Triple Pattern Fragments are the basis of our solution, we can interpret each fragment as a&nbsp;graph.
We will refer to these as *implicit graphs*.
This IRI can then be used as graph identifier for this triple for adding time information.
For example, the IRI for the triple `<s> <p> <o>` on the TPF interface located at `http://example.org/dataset/` is<br /> `http://example.org/dataset?subject=s&predicate=p&object=o`.

The choice of time annotation method for publishing temporal data will also depend on its capability to
*group* time labels.
If certain dynamic triples have identical time labels, these annotations can be shared to further reduce the required
amount of triples if we are using singleton properies or graphs.
When we would have three train delay triples which are valid for the same time interval using
graph annotation, these three triples can be placed in the same graph.
This will make sure they refer to the same time interval without having to replicate this annotation two times more.
In the case of implicit graph annotation, this grouping of triples is not possible, because each triple has a unique
graph identifier determined by the interface.
This would be possible if these different identifiers are linked to each other with
for example `owl:sameAs` relationships that our query engine takes into account, which would introduce further overhead.

We will execute our use case for each of these annotation methods.
In practice, an annotation method must be chosen depending on the requirements and available technologies.
If we have a datastore that supports quads, graph-based annotation is the best choice because of it requires the least amount of triples.
If our datastore does not support quads, we can use singleton properties.
If we have a TPF-like interface at which our data is hosted, we can use implicit graphs as annotation technique.
If however many of those triples can be grouped under the same time label, singleton properties are a better alternative because
the latter has grouping support.
