In this chapter, we address the first challenge of this PhD,
namely: "Experimentation requires *realistic* evolving data".
This challenge is a prerequisite to the next challenges, in which storage and querying techniques will be introduced.
In order to evaluate the performance of storage and querying systems that handle evolving knowledge graphs,
we must first have such knowledge graphs available to us.
Ideally, real-world knowledge graphs should be used,
as these can show the true performance of such systems in various circumstances.
However, these real-world knowledge graphs have limited public availability,
and do not allow for the required flexibility when evaluating systems.
For example, the evaluation of storage systems can require the ingestion of evolving knowledge graphs of varying sizes,
but real-world datasets only exist in fixed sizes.

To solve this problem, we focus on the generation of evolving knowledge graphs
assuming that we have population distributions as input.
For this, we started from the research question:
"Can population distribution data be used to generate realistic synthetic public transport networks and scheduling?"
Concretely, we introduce a _realistic_ mimicking algorithm for generating synthetic evolving knowledge graphs
with configurable sizes and properties.
The algorithm is based on established concepts from the domain of public transport networks design,
and takes population distributions as input to generate realistic transport networks.
The algorithm has been implemented in a system called _PoDiGG_,
and has been evaluated to measure its performance and level of realism.

