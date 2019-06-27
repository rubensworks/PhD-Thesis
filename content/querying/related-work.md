### Related Work
{:#querying_related-work}

In this section, we illustrate the many possible degrees of freedom for SPARQL query evaluation,
and show that they are hard to combine, which is the problem we aim to solve with Comunica.
We first discuss the SPARQL query language, its engines, and algorithms.
After that, we discuss alternative Linked Data publishing interfaces, and their connection to querying.
Finally, we discuss the software design patterns that are essential in the architecture of Comunica.

#### The Different Facets of SPARQL

[SPARQL](cite:cites spec:sparqllang) is the W3C-recommended RDF query language.
The traditional way to implement a SPARQL query processor
is to use it as an interface to an underlying database,
resulting in a so-called [_SPARQL endpoint_](cito:citeAsAuthority spec:sparqlprot).
This is similar to how an SQL interface
provides access to a relation database.
The internal storage can either be a native RDF store, e.g., [AllegroGraph](cito:citesAsAuthority allegrograph) and [Blazegraph](cito:citesAsAuthority blazegraph),
or a non-RDF store, e.g., [Virtuoso](cito:citesAsAuthority virtuoso) uses a object-relational database management system.

Various algorithms have been proposed for optimized SPARQL query evaluation.
Some algorithms for example use the concept of [query rewriting](cite:cites SparqlOptimization) based on algebraic equivalent query operations,
others have proposed the [optimization of Basic Graph Pattern evaluation](cite:cites SparqlSelectivityOptimization) using selectivity estimation of triple patterns.

In order to evaluate SPARQL queries over datasets of different storage types,
SPARQL query frameworks were developed, such as
[Jena (ARQ)](cite:cites jena), [RDFLib](cite:cites rdflib), [rdflib.js](cite:cites rdflibjs) and [rdfstore-js](cite:cites rdfstorejs).
Jena is a Java framework, RDFLib is a python package, and rdflib.js and rdfstore-js are JavaScript modules.
Jena—or more specifically the ARQ API—and RDFLib are fully [SPARQL 1.1](cite:cites spec:sparqllang) compliant.
rdflib.js and rdfstore-js both support a subset of SPARQL 1.1.
These SPARQL engines support in-memory models or other sources,
such as Jena TDB in the case of ARQ.
Most of the query algorithms are tightly coupled to these frameworks,
which makes swapping out query algorithms for specific query operators hard or sometimes even impossible.
Furthermore, complex things such as federated querying over heterogeneous interfaces are difficult to implement using these frameworks,
as they are not supported out-of-the-box.
This issue of modularity and heterogeneity are two of the main problems we aim to solve within Comunica.
The differences between Comunica and existing frameworks will be explained in more detail in [](#features).

The [Triple Pattern Fragments client](cite:cites ldf) (also known as Client.js or `ldf-client`) is a client-side SPARQL engine
that retrieves data over HTTP
through [Triple Pattern Fragments (TPF) interfaces](cite:cites ldf).
[Different algorithms](cite:cites tpfoptimization, cyclades, tpfqs) for this client and
[TPF interface extensions](cite:cites tpfamf, tpfsubstring, brtpf, vtpf) have been proposed to reduce effort of server or client in some way.
All of these efforts are however implemented and evaluated in isolation.
Furthermore, the implementations are tied to TPF interface, which makes it impossible to use them for other types of datasources and interfaces.
With Comunica, we aim to solve this by modularizing query operation implementations into separate modules,
so that they can be plugged in and combined in different ways, on top of different datasources and interfaces.

With Semantic Web technologies providing the capability
to integrate data from different sources,
_federated query processing_ has been an active area of research.
However, most of the existing frameworks require SPARQL endpoints on every source.
The TPF Client instead federates over TPF interfaces,
and achieves [similar performance compared to the state of the art](cito:citesAsEvidence ldf)
despite its usage of a more lightweight interface.
However, no frameworks exist that enable federation over heterogeneous interfaces,
such as the federation over any combination of SPARQL endpoints and TPF interfaces.
With Comunica, we aim to fill this gap.
In addition dataset-centric approaches,
alternative methods such as [link-traversal-based query evaluation](cite:cites linkeddataqueries) exist
to query a web of Linked Data documents.

#### Linked Data Fragments

In order to formally capture the heterogeneity of different Web interfaces to publish RDF data,
the [Linked Data Fragment](cite:cites ldf) (LDF) conceptual framework
uniformly characterizes responses of Web interfaces to RDF-based knowledge graphs.
The simplest type of LDF is a _data dump_---it is the response of a single HTTP requests for a complete RDF dataset.
Other types of LDFs includes responses of SPARQL endpoints,
TPF interfaces, and Linked Data documents.

Existing LDF research highlights that,
when it comes to publishing datasets on the Web, there is no silver bullet:
no single interface works well in all situations,
as each one involves [trade-offs](cito:citesAsEvidence ldf).
As such, data publishers must choose the type of interface that matches their intended use case, target audience and infrastructure.
This however complicates client-side engines that need to retrieve data from the resulting heterogeneity of interfaces.
As shown by the TPF approach, interfaces can be self-descriptive and expose one or more [features](cite:cites webapifeatures),
to describe their functionality using a [common vocabulary](cite:cites hydra,describingapiresponses).
This allows clients without prior knowledge of the exact inputs and outputs of an interface
to discover its usage at runtime.

A design goal of Comunica is to
facilitate interaction with any current and future interface
within the LDF framework,
both in single-source and federated scenarios.

#### Software Design Patterns

In the following, we discuss three software design patterns that are relevant to the modular design of the Comunica engine.

##### Publish–subscribe pattern

The [_publish-subscribe_](cite:cites publishsubscribepattern) design pattern involves passing _messages_ between _publishers_ and _subscribers_.
Instead of programming publishers to send messages directly to subscribers, they are programmed to _publish_ messages to certain _categories_.
Subscribers can _subscribe_ to these categories which will cause them to receive these published messages, without requiring prior knowledge of the publishers.
This pattern is useful for decoupling software components from each other,
and only requiring prior knowledge of message categories.
We use this pattern in Comunica for allowing different implementations of certain tasks to subscribe to task-specific buses.

##### Actor Model

The [_actor_ model](cite:cites actormodel) was designed as a way to achieve highly parallel systems consisting of many independent _agents_
communicating using messages, similar to the publish–subscribe pattern.
An actor is a computational unit that performs a specific task, acts on messages, and can send messages to other actors.
The main advantages of the actor model are that actors can be independently made to implement certain specific tasks based on messages,
and that these can be handled asynchronously.
These characteristics are highly beneficial to the modularity that we want to achieve with Comunica.
That is why we use this pattern in combination with the publish–subscribe pattern to let each implementation of a certain task correspond to a separate actor.

##### Mediator pattern

The [_mediator_](cite:cites mediatorpattern) pattern is able to reduce coupling between software components that interact with each other,
and to easily change the interaction if needed.
This can be achieved by encapsulating the interaction between software components in a mediator component.
Instead of the components having to interact with each other directly,
they now interact through the mediator.
These components therefore do not require prior knowledge of each other,
and different implementations of these mediators can lead to different interaction results.
In Comunica, we use this pattern to handle actions when multiple actors are able to solve the same task,
by for example choosing the _best_ actor for a task, or by combining the solutions of all actors.
