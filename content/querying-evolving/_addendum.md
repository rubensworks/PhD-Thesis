<div style="page-break-after: always;">&nbsp;</div>

### Addendum
{:#querying-evolving_addendum}

In this section, I summarize the follow-up work that has been done
since the article corresponding to this chapter has been published.
Concretely, I focus on ["On the Semantics of TPF-QS towards Publishing and Querying RDF Streams at Web-scale"](cite:cites tpfqs2)
that has been published two years after the work from this chapter.
This article aims to resolve some of the initial weaknesses.
Concretely, a proper formalization is introduced, using which the system (TPF-QS) is compared using alternative RDF stream processing systems.
Furthermore, a more extensive evaluation is done using a state of the art benchmark.
These two parts are summarized hereafter.

#### Formalization

[RSP-QL](cite:cites rspql) is a formal reference model in which different
RDF Stream Processing (RSP) systems can be compared to each other,
such as [C-SPARQL](cite:cites csparql), [CQELS](cite:cites cqels) and [TPF-QS](tpfqs).
It can be seen as an extension of RDF and SPARQL, by introducing temporal semantics.
In the next paragraphs, I will summarize the RSP-QL model,
explain how TPF-QS fits into this,
and how TPF-QS can be compared to alternative RSP systems using this model.
I will omit the details and full formal definitions that can be found in the [full paper](cite:cites tpfqs2).

**RSP-QL Overview**

RSP-QL introduces the concept of an *RDF stream*
that is defined as an unbounded sequence of pairs.
Each pair consists of an RDF statement and a time instant.

In order to query RDF streams, the concept of an RDF dataset was extended to an *RSP-QL dataset*.
Such a dataset consists of an optional default graph, zero or more named graphs, and zero or more (named) *time-varying graphs*.
A time-varying graph is a function that maps time instants to instantaneous RDF graphs.

To avoid querying over very large streams, the concept of a *time-based window* was introduced.
A time-based window is defined by a certain width, a slide parameter, and a starting time,
where all of these parameters are expressed in time units.
Concretely, such a window takes an RDF stream as input, and produces a time-varying graph.

To model the different ways in which repeated query evaluation can occur,
so-called *evaluation strategies* were introduced.
For example, the *Content Change (CC)* strategy makes the window report results when window contents change.
*Window Close (WC)* reports when the window closes.
The *Non-empty Content (NC)* strategy reports if the active window is not empty.
The *Periodic* (P) stategy reports at regular time intervals.

Finally, after windowing, query execution results can be reported in different ways,
where each of them adds time annotations to the solution mappings.
*RStream* annotates an input sequence of solution mappings with the evaluation time;
*IStream* streams the difference between the answer of the current evaluation and the one of the previous iteration;
*DStream* streams the part of the answer at the previous iteration that is not in the current one.

**TPF-QS in terms of RSP-QL**

From the perspective of a TPF-QS client, the data that was retrieved from a TPF server
can be interpreted as an RSP-QL stream, for which we introduced a formal mapping.
Based on this, all elements of the RSP-QL model can be applied.

Windows within TPF-QS can have a configurable starting time,
and always have a width and slide parameter of exactly one time unit.
As a consequence, the evaluation of a window in TPF-QS
will always produce a time-varying graph that contains exactly one instantaneous RDF graph.

TPF-QS supports two configurable evaluation strategies: *Periodic* and *Mapping Expire (ME)*.
The Mapping Expire strategy is specific to TPF-QS, and is possible
because of the time validity annotations that are exposed by TPF servers.
In summary, Mapping Expire will make the window report when the validity
of an RDF statement that was used in the last solution mapping expires.

**RSP-QL Comparison**

[](#querying-evolving_rspqp-comparison) compares the TPF-QS with C-SPARQL and CQELS in terms of the RSP-QL reference model.

<figure id="querying-evolving_rspqp-comparison" class="table" markdown="1">

| **Feature**             | **TPF-QS** | **C-SPARQL** | **CQELS** |
| ----------------------- |------------|--------------|-----------|
| **volatile RDF stream** | no | yes | yes |
| **data retrieval**      | pull | push | push |
| **time annotation**     | time interval | timestamp | timestamp |
| **window parameters**   | configurable starting time, width and slide of one time unit | fixed starting time, configurable width and slide | fixed starting time, configurable width and slide |
| **RSP-QL dataset**      | time varying graph in default graph | time varying graph in default graph | named time varying graph |
| **window policy**       | ME, P | WC, NC | CC |
| **streaming operators** | RStream | RStream | IStream |

<figcaption markdown="block">
Comparison TPF-QS, C-SPARQL, and CQELS in terms of the main elements of the RSP-QL reference model.
</figcaption>
</figure>

#### Evaluation

While the experiments that were presented in this chapter made use of a relatively small dataset with simple queries,
our new experiments made use of the [CityBench](cite:cites citybench) benchmark.
Using this benchmark, large-scale real-world sensor data streams were used together with a set of realistic queries, ranging from simple to complex.
For an increasing number of clients, we measured server CPU usage, result latency, result completeness.
Using CityBench, we compared TPF-QS with C-SPARQL and CQELS.
Our findings show that TPF-QS results in lower server load and latency for simple queries,
but higher for complex queries.
Due to slower evaluation, TPF-QS sometimes results in lower result completeness than the alternatives.

Results clearly show that when stream volatility is constant, and queries are not too complex,
TPF-QS outperforms alternative systems in terms of server load for an increasing number of clients.
However, there is still a limit in the number of concurrent clients that can be achieved,
since the results have shown that result latencies start increasing for high numbers of clients.
This shows that TPF-QS should only be used in specific use cases,
and that additional follow-up work is required to make it more widely applicable.
