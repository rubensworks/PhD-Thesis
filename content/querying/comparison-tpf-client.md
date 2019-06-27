### Performance Analysis
{:#querying_comparison-tpf-client}

One of the goals of Comunica is to replace the TPF Client as a more *flexible* and *modular* alternative,
with at least the same *functionality* and similar *performance*.
The fact that Comunica supports multiple heterogeneous interfaces and sources as shown in the previous section
validates this flexibility and modularity, as the TPF Client only supports querying over TPF interfaces.

Next to a functional completeness, it is also desired that Comunica achieves similar *performance* compared to the TPF Client.
The higher modularity of Comunica is however expected to cause performance overhead,
due to the additional bus and mediator communication, which does not exist in the TPF Client.
Hereafter, we compare the performance of the TPF Client and Comunica
and discover that Comunica has similar performance to the TPF Client.
As the main goal of Comunica is modularity, and not _absolute_ performance, we do not compare with similar frameworks such as ARQ and RDFLib.
Instead, _relative_ performance of evaluations using _the same engine_ under _different configurations_ is key for comparisons,
which will be demonstrated using Comunica hereafter.

For the setup of this evaluation we used a single machine (Intel Core i5-3230M CPU at 2.60 GHz with 8 GB of RAM),
running the Linked Data Fragments server with a [HDT-backend](cite:cites hdt) and the TPF Client or Comunica,
for which the exact versions and configurations will be linked in the following workflow.
The main goal of this evaluation is to determine the performance impact of Comunica,
while keeping all other variables constant.

In order to illustrate the benefit of modularity within Comunica,
we evaluate using two different configurations of Comunica.
The first configuration (_Comunica-sort_) implements a BGP algorithm that is similar to that of the original TPF Client:
it sorts triple patterns based on their estimated counts and evaluates and joins them in that order.
The second configuration (_Comunica-smallest_) implements a simplified version of this BGP algorithm that does not sort _all_ triple patterns in a BGP,
but merely picks the triple pattern with the smallest estimated count to evaluate on each recursive call, leading to slightly different query plans.

We used the following <a about="#evaluation-workflow" content="Comunica evaluation workflow" href="#evaluation-workflow" property="rdfs:label" rel="cc:license" resource="https://creativecommons.org/licenses/by/4.0/">evaluation workflow</a>:

<ol id="evaluation-workflow" property="schema:hasPart" resource="#evaluation-workflow" typeof="opmw:WorkflowTemplate" markdown="1">
<li id="workflow-data" about="#workflow-data" typeof="opmw:WorkflowTemplateProcess" rel="opmw:isStepOfTemplate" resource="#evaluation-workflow" property="rdfs:label" markdown="1">
  Generate a [WatDiv](cite:cites watdiv) dataset with scale factor=100.
</li>
<li id="workflow-queries" about="#workflow-queries" typeof="opmw:WorkflowTemplateProcess" rel="opmw:isStepOfTemplate" resource="#evaluation-workflow" property="rdfs:label" markdown="1">
  Generate the corresponding default WatDiv [queries](https://github.com/comunica/test-comunica/tree/ISWC2018/sparql/watdiv-10M){:.mandatory} with query-count=5.
</li>
<li id="workflow-tpf-server" about="#workflow-tpf-server" typeof="opmw:WorkflowTemplateProcess" rel="opmw:isStepOfTemplate" resource="#evaluation-workflow" property="rdfs:label" markdown="1">
  Install [the server software configuration](https://linkedsoftwaredependencies.org/raw/ldf-availability-experiment-config.jsonld){:.mandatory}, implementing the [TPF specification](https://www.hydra-cg.com/spec/latest/triple-pattern-fragments/){:.mandatory}, with its [dependencies](https://linkedsoftwaredependencies.org/raw/ldf-availability-experiment-setup.ttl){:mandatory}.
</li>
<li id="workflow-tpf-client" about="#workflow-tpf-client" typeof="opmw:WorkflowTemplateProcess" rel="opmw:isStepOfTemplate" resource="#evaluation-workflow" property="rdfs:label" markdown="1">
  Install [the TPF Client software](https://github.com/LinkedDataFragments/Client.js){:.mandatory}, implementing the [SPARQL 1.1 protocol](https://www.w3.org/TR/sparql11-protocol){:mandatory}, with its [dependencies](https://linkedsoftwaredependencies.org/raw/ldf-availability-experiment-client.ttl){:.mandatory}.
</li>
<li id="workflow-tpf-run" about="#workflow-tpf-run" typeof="opmw:WorkflowTemplateProcess" rel="opmw:isStepOfTemplate" resource="#evaluation-workflow" property="rdfs:label" markdown="1">
  Execute the generated WatDiv queries 3 times on the TPF Client, after doing a warmup run, and record the execution times [results](https://raw.githubusercontent.com/comunica/test-comunica/master/results/watdiv-ldf.csv){:.mandatory}.
</li>
<li id="workflow-comunica-sort" about="#workflow-comunica-srt" typeof="opmw:WorkflowTemplateProcess" rel="opmw:isStepOfTemplate" resource="#evaluation-workflow" property="rdfs:label" markdown="1">
  Install [the Comunica software configuration](https://raw.githubusercontent.com/comunica/test-comunica/master/config/config-sort.json){:.mandatory}, implementing the [SPARQL 1.1 protocol](https://www.w3.org/TR/sparql11-protocol){:mandatory}, with its [dependencies](https://raw.githubusercontent.com/comunica/test-comunica/master/config/comunica-npm.ttl){:.mandatory}, using the _Comunica-sort_ algorithm.
</li>
<li id="workflow-comunica-run-sort" about="#workflow-comunica-run-sort" typeof="opmw:WorkflowTemplateProcess" rel="opmw:isStepOfTemplate" resource="#evaluation-workflow" property="rdfs:label" markdown="1">
  Execute the generated WatDiv queries 3 times on the Comunica client, after doing a warmup run, and record the [execution times](https://raw.githubusercontent.com/comunica/test-comunica/master/results/watdiv-comunica-sort.csv){:.mandatory}.
</li>
<li id="workflow-comunica-smallest" about="#workflow-comunica-smallest" typeof="opmw:WorkflowTemplateProcess" rel="opmw:isStepOfTemplate" resource="#evaluation-workflow" property="rdfs:label" markdown="1">
  Update the Comunica installation to use a new [configuration](https://raw.githubusercontent.com/comunica/test-comunica/master/config/config-smallest.json){:.mandatory} supporting the _Comunica-smallest_ algorithm.
</li>
<li id="workflow-comunica-run-smallest" about="#workflow-comunica-run-smallest" typeof="opmw:WorkflowTemplateProcess" rel="opmw:isStepOfTemplate" resource="#evaluation-workflow" property="rdfs:label" markdown="1">
  Execute the generated WatDiv queries 3 times on the Comunica client, after doing a warmup run, and record the [execution times](https://raw.githubusercontent.com/comunica/test-comunica/master/results/watdiv-comunica.csv){:.mandatory}.
</li>
</ol>

<figure id="querying_performance-average">
<center>
<img src="querying/img/avg.svg" alt="[performance-average]" class="plot">
<img src="querying/img/avg_c23.svg" alt="[performance-average]" class="plot">
</center>
<figcaption markdown="block">
Average query evaluation times for the TPF Client, Comunica-sort, and Comunica-smallest for all queries (shorter is better).
C2 and C3 are shown separately because of their higher evaluation times.
</figcaption>
</figure>

The results from [](#querying_performance-average) show that Comunica is able to achieve similar performance compared to the TPF Client.
Concretely, both Comunica variants are faster for 11 queries, and slower for 9 queries.
However, the difference in evaluation times is in most cases very small,
and are caused by implementation details, as the implemented algorithms are equivalent.
Contrary to our expectations, the performance overhead of Comunica's modularity is negligible.
Comunica therefore improves upon the TPF Client in terms of *modularity* and *functionality*, and achieves similar *performance*.

These results also illustrate the simplicity of comparing different algorithms inside Comunica.
In this case, we compared an algorithm that is similar to that of the original TPF Client with a simplified variant.
The results show that the performance is very similar, but the original algorithm (Comunica-sort) is faster in most of the cases.
It is however not always faster, as illustrated by query C1, where Comunica-sort is almost a second slower than Comunica-smallest.
In this case, the heuristic algorithm of the latter was able to come up with a slightly better query plan.
Our goal with this result is to show that Comunica can easily be used to compare such different algorithms,
where future work can focus on smart mediator algorithms to choose the best BGP actor in each case.
