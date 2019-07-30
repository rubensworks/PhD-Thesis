### Research Question
{:#generating_research-question}

In order to generate public transport networks and schedules,
we start from the hypothesis that both
are correlated with the population distribution within the same area.
More populated areas are expected to have more nearby and more frequent access to public transport,
corresponding to the [recurring demand satisfaction objective in public transit planning](cite:cites transitnetworkdesignscheduling).
When we calculate the correlation
between the distribution of stops in an area and its population distribution,
we discover a positive correlation of 0.439 for Belgium and 0.459 for the Netherlands (*p*-values in both cases &lt; 0.00001),
thereby validating our hypothesis with a confidence of 99%.
Because of the continuous population variable and the binary variable indicating whether or not there is a stop,
the correlation is calculated using the [point-biserial correlation coefficient](https://github.com/PoDiGG/podigg-evaluate/blob/master/stats/correlation.r){:.mandatory}.
For the calculation of these correlations, we ignored the population value outliers.
Following this conclusion, our mimicking algorithm will use such population distributions as input,
and derive public transport networks and trip instances.

<meta property="lsc:tests" resource="#generating_hypothesis">
<meta about="#generating_hypothesis" property="schema:name" content="Public transport networks and schedules are correlated with the population distribution within the same area.">
<meta property="lsc:confirms" resource="#generating_hypothesis">

The main objective of a mimicking algorithm is to create *realistic* data,
so that it can be used to by benchmarks to evaluate systems under realistic circumstances.
We will measure dataset realism in high-level by comparing the levels of structuredness
of real-world datasets and their synthetic variants
using the *coherence metric* introduced by [Duan et al.](cite:cites rdfbenchmarksdatasets).
Furthermore, we will measure the realism of different characteristics within public transport datasets,
such as the location of stops, density of the network of stops, length of routes or the frequency of connections.
We will quantify these aspects by measuring the distance of each aspect between real and synthetic datasets.
These dataset characteristics will be linked with potential evaluation metrics within RDF data management systems,
and tasks to evaluate them.
This generic coherence metric together with domain-specific metrics will provide a way to evaluate dataset realism.

Based on this, we introduce the following research question for this work:

<div rel="schema:question" markdown="1">
> Can population distribution data be used to generate realistic synthetic public transport networks and scheduling?
{:#generating_researchquestion about="#generating_researchquestion" property="schema:name"}
</div>

We provide an answer to this question by first introducing an
algorithm for generating public transport networks and their scheduling based on population distributions in [](#generating_methodology).
After that, we validate the realism of datasets that were generated using an implementation of this algorithm in [](#generating_evaluation).
