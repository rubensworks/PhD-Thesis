### Introduction
{:#querying_introduction}

Linked Data on the Web exists in many shapes and forms—and
so do the processors we use to query data from one or multiple sources.
For instance,
engines that query RDF data using the [SPARQL language](cito:citesAsAuthority spec:sparqllang)
employ [_different algorithms_](cito:cites SparqlOptimization, SparqlSelectivityOptimization)
and support [_different language extensions_](cito:cites Erling2009, fSPARQL).
Furthermore,
Linked Data is increasingly published through _different Web interfaces_,
such as
data dumps, [Linked Data documents](cite:cites LinkedDataPrinciples),
[SPARQL endpoints](cite:cites spec:sparqlprot)
and [Triple Pattern Fragments (TPF) interfaces](cite:cites ldf).
This has led to entirely different query evaluation strategies,
such as [server-side](cite:cites spec:sparqlprot),
[link-traversal-based](cite:cites linkeddataqueries),
[shared client–server query processing](cite:cites ldf),
and
client-side (by downloading data dumps and loading them locally).

The resulting variety of implementations
suffers from two main problems:
a lack of _sustainability_
and a lack of _comparability_.
Alternative query algorithms and features
are typically either implemented as [_forks_ of existing software packages](cito:cites tpfoptimization,tpfamf,tpfsubstring)
or as [_independent_ engines](cito:cites acosta_iswc_2015).
This practice has limited sustainability:
forks are often not merged into the main software distribution
and hence become abandoned;
independent implementations require a considerable upfront cost
and also risk abandonment more than established engines.
Comparability is also limited:
forks based on older versions of an engine
cannot meaningfully be evaluated against newer forks,
and evaluating _combinations_ of cross-implementation features—such as
different algorithms on different interfaces—is
not possible without code adaptation.
As a result, many interesting comparisons are never performed
because they are too costly to implement and maintain.
For example,
it is currently unknown
how the [Linked Data Eddies algorithm](cito:citesAsAuthority acosta_iswc_2015)
performs over a [federation](cito:cites ldf)
of [brTPF interfaces](cito:cites brtpf).
Another example is that the effects of various [optimizations and extensions for TPF interfaces](cite:cites tpfoptimization, tpfamf, tpfsubstring, acosta_iswc_2015, brtpf, vtpf, cyclades, tpfqs)
have only been evaluated in isolation,
whereas certain combinations will likely prove complementary.

In order to handle the increasing heterogeneity of Linked Data on the Web,
as well as various solutions for querying it,
there is a need for a flexible and modular query engine
to experiment with all of these techniques—both separately and in combination.
In this article, we introduce _Comunica_ to realize this vision.
It is a highly modular meta engine for federated SPARQL query evaluation
over heterogeneous interfaces,
including TPF interfaces, SPARQL endpoints, and data dumps.
Comunica aims to serve as a flexible research platform for
designing, implementing, and evaluating
new and existing Linked Data querying and publication techniques.

Comunica differs from existing query processors on different levels:

1. The **modularity** of the Comunica meta query engine allows for
_extensions_ and _customization_ of algorithms and functionality.
Users can build and fine-tune a concrete engine
by wiring the required modules through an RDF configuration document.
By publishing this document,
experiments can repeated and adapted by others.
2. Within Comunica, multiple **heterogeneous interfaces** are first-class citizens. This enables federated querying over heterogeneous sources and makes it for example possible to evaluate queries over any combination of SPARQL endpoints, TPF interfaces, datadumps, or other types of interfaces.
3. Comunica is implemented using **Web-based technologies** in JavaScript, which enables usage through browsers, the command line, the [SPARQL protocol](cite:cites spec:sparqlprot), or any Web or JavaScript application.

Comunica and its default modules are publicly available
on GitHub and the npm package manager under the open-source MIT license
(canonical citation: [https://zenodo.org/record/1202509#.Wq9GZhNuaHo](https://zenodo.org/record/1202509#.Wq9GZhNuaHo)).

This article is structured as follows.
In the next section, we discuss the related work, followed by the main features of Comunica in [](#querying_features).
After that, we introduce the architecture of Comunica in [](#querying_architecture), and its implementation in [](#querying_implementation).
Next, we compare the performance of different Comunica configurations with the TPF Client in [](#querying_comparison-tpf-client).
Finally, [](#querying_conclusions) concludes and discusses future work.
