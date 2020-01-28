### Conclusions
{:#querying-evolving_conclusions}

In this paper, we researched a solution for querying over dynamic data with a low server cost,
by continuously polling the data based on volatility information.
In this section, we draw conclusions from our evaluation results to give an answer
to the research questions and hypotheses we defined in [](#querying-evolving_problem-statement).
First, the server and client costs for our solution will be compared with the alternatives.
After that, the effect of our client-side cache will be explained.
Next, we will discuss the effect of time annotation on the amount of requests to be sent, after which the
performance of our solution will be shown and the effects of the annotation methods.

<div class="printonly empty-page">&nbsp;</div>

#### Server cost
The results from [](#querying-evolving_subsec:Results-ServerCost) confirm [Hypothesis 1](#querying-evolving_hypothesis1), in which we wanted to
know if we could lower the server cost when compared to C-SPARQL and CQELS.
Not only is the server cost for our solution more than ten times lower on average when compared to the alternatives,
this cost also increases much slower for a growing number of simultaneous clients.
This makes our proposed solution more scalable for the server.
Another disadvantage of C-SPARQL and CQELS is the fact that the server load for a large number of
concurrent clients varies significantly, as can be seen in [](#querying-evolving_fig:res:scalability-server-200).
This makes it hard to scale the required processing powers for servers using these technologies.
Our solution has a low and more constant CPU usage.

<meta property="lsc:confirms" resource="#querying-evolving_hypothesis1">

#### Client cost
The results for the client load measurements from [](#querying-evolving_subsec:Results-ClientCost) confirm
[Hypothesis 2](#querying-evolving_hypothesis2), which stated that our solution increases the client's processing need.
The required client processing power using our solution is clearly much higher than for C-SPARQL and CQELS.
This is because we redistributed the required processing power from the server to the client.
In our solution, it is the client that has to do most of the work for evaluating queries, which puts
less load on the server.
The load on the client still remains around 5% for the largest part of the query evaluation
as shown in [](#querying-evolving_fig:res:scalability-client). Only during the first few seconds, the query engines
CPU usage peaks, which is because of the processor-intensive rewriting step that needs to be done once
at the start of each dynamic query evaluation.

<meta property="lsc:confirms" resource="#querying-evolving_hypothesis2">

#### Caching
We can also confirm [Hypothesis 3](#querying-evolving_hypothesis3) about the positive effect of caching
from the results in [](#querying-evolving_subsec:Results-AnnotationMethods).
Our caching solution has a positive effect on the execution times.
In an optimal scenario for our use case, caching would lead to an execution time reduction of 60% because three of the five triple
patterns in the query for our use case from [](#querying-evolving_use-case) are static.
For our results, this caching leads to an average reduction of 56% which is close to the optimal case.
Since we are working with dynamic data, some required background-data is bound to overlap, in these
cases it is advantageous to have a client-side caching solution so that these redundant requests for
static data can be avoided.
The longer our query evaluation runs, the more static data the cache accumulates, so the bigger the
chance that there are cache hits when background data is needed in a certain query iteration.
Future research should indicate what the limits of such a client-side cache for static data are, and
whether or not it is advantageous to reuse this cache for different queries.

<meta property="lsc:confirms" resource="#querying-evolving_hypothesis3">

<div class="printonly empty-page">&nbsp;</div>

#### Request reduction
By annotating dynamic data with a time annotation, we successfully reduced the amount of required requests
for polling-based SPARQL querying to a minimum, which answers [Research Question 1](#querying-evolving_researchquestion1)
about the question if clients can use volatility knowledge to perform continuous querying.
Because now, the client can derive the exact moment at which the data can change on the server, and this will be used
to schedule a new query execution on the server.
In future research, it is still possible to reduce the amount of requests our client engine needs to send
through a better caching strategy, which could for example also temporarily cache dynamic data which changes
at different frequencies.
We can also look into differential data transmission by only sending data to the client that has been changed since
the last time the client has requested a specific resource.

#### Performance
For answering [Research Question 2](#querying-evolving_researchquestion2), the performance of our solution compared to alternatives,
we compared our solution with two state-of-the-art approaches for dynamic SPARQL querying.
Our solution significantly reduces the required server processing per client, this complexity is mostly moved to the client.
This comparison shows that our technique allows data providers to offer dynamic data which can be used to continuously
evaluate dynamic queries with a low server cost.
Our low-cost publication technique for dynamic data is useful when the number of potential simultaneous clients
is large. When this data is needed for only a small number of clients in a closed off environment
and query evaluation must happen fast, traditional approaches like CQELS or C-SPARQL are advised.
These are only two possible points on the [*Linked Data Fragments* axis](cite:cites ldf), depending on the
publication requirements, combinations of these approaches can be&nbsp;used.

#### Annotation methods
In [Research Question 3](#querying-evolving_researchquestion3), we wanted to know how the different annotation methods influenced the execution times.
From the results in [](#querying-evolving_subsec:Results-AnnotationMethods), we can conclude that graph-based annotation results in the lowest execution times.
It can also be seen that annotation with time intervals has the problem of continuously increasing execution times, because
of the continuously growing dataset. Time interval annotation can be desired if we for example want to maintain
the history of certain facts, as opposed to just having the last version of facts using expiration times.
In future work, we will investigate alternative techniques to support time interval annotation without the continuously increasing execution times.

In this work, the frequency at which our queries are updated is purely data-driven using time intervals or expiration times.
In the future it might be interesting, to provide a control to the user to change this frequency, if for example this user
only desires query updates at a lower frequency than the data actually changes.

In future work, it is important to test this approach with a larger variety of use cases.
The time annotation mechanisms we use are generic enough to
transform all static facts to dynamic data for any number of triples.
The [CityBench](cite:cites citybench) benchmark can for example be
used to evaluate these different cases based on city sensor data.
These tests must be scaled (both in terms of clients as in terms of dataset size),
so that the maximum number of concurrent requests can be determined, with respect to the dataset&nbsp;size.
