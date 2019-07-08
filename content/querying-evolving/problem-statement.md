### Problem Statement
{:#querying-evolving_problem-statement}

In order to lower server load during continuous query evaluation,
we move a significant part of the query evaluation from server to client.
We annotate dynamic data with their valid time to make it possible for clients
to derive an optimal query evaluation frequency.

For this research, we identified the following research questions:

>Can clients use volatility knowledge to perform more efficient continuous SPARQL query evaluation by polling for data?
{:#querying-evolving_researchquestion1}

>How does the client and server load of our solution compare to alternatives?
{:#querying-evolving_researchquestion2}

> How do different time-annotation methods perform in terms of the resulting execution times?
{:#querying-evolving_researchquestion3}

These research questions lead to the following hypotheses:

<ol>
    <li id="querying-evolving_hypothesis1">The proposed framework has a lower server cost than alternatives.</li>
    <li id="querying-evolving_hypothesis2">The proposed framework has a higher client cost than streaming-based SPARQL approaches for equivalent queries.</li>
    <li id="querying-evolving_hypothesis3">Client-side caching of static data reduces the execution times proportional to the fraction of static triple patterns that are present in the query.</li>
</ol>
