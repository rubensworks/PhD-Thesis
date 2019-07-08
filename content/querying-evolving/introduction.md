### Introduction
{:#querying-evolving_introduction}

As the Web of Data is a *dynamic* dataspace, different results may be returned depending on when a question was asked.
The end-user might be interested in seeing the query results update over time,
for instance, by re-executing the entire query over and over again ("polling").
This is, however, not very practical,
especially if it is unknown beforehand when data will change.
An additional problem is that
[many public (even static) SPARQL query endpoints suffer from a low availability](cite:cites buil2013sparql).
The [unrestricted complexity of SPARQL queries](cite:cites sparqlcomplexity) combined
with the public character of SPARQL endpoints entails a&nbsp;high server cost, which makes it expensive to host such an interface with high availability.
*Dynamic* SPARQL streaming solutions offer combined access to dynamic data streams and
static background data through continuously executing queries. Because of this continuous querying, the cost
for these servers is even higher than with static querying.

In this work, we therefore devise a solution that enables clients to continuously evaluate non-high frequency
queries by polling specific fragments of the data.
The&nbsp;resulting&nbsp;framework performs this without the server needing to remember any client state.
Its mechanism requires the server to *annotate* its data so that the client can efficiently determine when to retrieve fresh data.
The generic approach in this paper is applied to the use case of public transit route planning.
It can be used in various other domains with continuously updating data, such as smart city dashboards, business intelligence, or sensor networks.
This paper extends our [earlier work](cite:cites taelman_mepdaw_2016) with additional experiments.

In the next section, we discuss related research on which our solution will be based.
After that, [](#querying-evolving_problem-statement) gives a general problem statement.
In [](#querying-evolving_use-case), we present a motivating use case.
[](#querying-evolving_dynamic-data-representation) discusses different techniques to represent dynamic data,
after which [](#querying-evolving_query-engine) gives an explanation of our proposed query solution.
Next, [](#querying-evolving_evaluation) shows an overview of our experimental setup and its results.
Finally, [](#querying-evolving_conclusions) discusses the conclusions of this work with further research opportunities.
