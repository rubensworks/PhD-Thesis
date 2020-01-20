### Architecture
{:#querying_architecture}

In this section, we discuss the design and architecture of the Comunica meta engine,
and show how it conforms to the _modularity_ feature requirement.
In summary, Comunica is collection of small modules that, when wired together,
are able to perform a certain task, such as evaluating SPARQL queries.
We first discuss the customizability of Comunica at design-time,
followed by the flexibility of Comunica at run-time.
Finally, we give an overview of all modules.

#### Customizable Wiring at Design-time through Dependency Injection

There is no such thing as _the_ Comunica engine.
Instead, Comunica is a meta engine that can be _instantiated_ into different engines based on different configurations.
Comunica achieves this customizability at design-time using the concept of [_dependency injection_](cite:cites DependencyInjection).
Using a configuration file, which is created before an engine is started,
components for an engine can be _selected_, _configured_ and _combined_.
For this, we use the [Components.js](cite:cites componentsjs) JavaScript dependency injection framework.
This framework is based on semantic module descriptions and configuration files
using the [Object-Oriented Components ontology](cite:cites vanherwegen_semsci_2017).

##### Description of Individual Software Components

In order to refer to Comunica components from within configuration files,
we semantically describe all Comunica components using the Components.js framework in [JSON-LD](cite:cites jsonld).
[](#querying_config-actor) shows an example of the semantic description of an RDF parser.

##### Description of Complex Software Configurations

A specific instance of a Comunica engine
can be _initialized_ using Components.js configuration files
that describe the wiring between components.
For example, [](#querying_config-parser) shows a configuration file of an engine that is able to parse N3 and JSON-LD-based documents.
This example shows that, due to its high degree of modularity,
Comunica can be used for other purposes than a query engine,
such as building a custom RDF parser.

Since many different configurations can be created,
it is important to know which one was used for a specific use case or evaluation.
For that purpose,
the RDF documents that are used to instantiate a Comunica engine
can be [published as Linked Data](cito:citeAsEvidence vanherwegen_semsci_2017).
They can then serve as provenance
and as the basis for derived set-ups or evaluations.

<figure id="querying_config-actor" class="listing">
````/querying/code/config-actor.json````
<figcaption markdown="block">
Semantic description of a component that is able to parse N3-based RDF serializations.
This component has a single parameter that allows media types to be registered that this parser is able to handle.
In this case, the component has four default media types.
</figcaption>
</figure>

<figure id="querying_config-parser" class="listing">
````/querying/code/config-parser.json````
<figcaption markdown="block">
Comunica configuration of `ActorInitRdfParse` for parsing an RDF document in an unknown serialization.
This actor is linked to a mediator with a bus containing two RDF parsers for specific serializations.
</figcaption>
</figure>

#### Flexibility at Run-time using the Actor–Mediator–Bus Pattern

Once a Comunica engine has been configured and initialized,
components can interact with each other in a flexible way using the [_actor_](cite:cites actormodel),
[_mediator_](cite:cites mediatorpattern), and [_publish–subscribe_](cite:cites publishsubscribepattern) patterns.
Any number of _actor_, _mediator_ and _bus_ modules can be created,
where each actor interacts with mediators, that in turn invoke other actors that are registered to a certain bus.

[](#querying_actor-mediator-bus) shows an example logic flow between actors through a mediator and a bus.
The relation between these components, their phases and the chaining of them will be explained hereafter.

<figure id="querying_actor-mediator-bus">
<img src="querying/img/actor-mediator-bus.svg" alt="[actor-mediator-bus pattern]" class="figure-small">
<figcaption markdown="block">
Example logic flow where Actor 0 requires an _action_ to be performed.
This is done by sending the action to the Mediator, which sends a _test action_ to Actors 1, 2 and 3 via the Bus.
The Bus then sends all _test replies_ to the Mediator,
which chooses the best actor for the action, in this case Actor 3.
Finally, the Mediator sends the original action to Actor 3, and returns its response to Actor 0.
</figcaption>
</figure>

##### Relation between Actors and Buses

Actors are the main computational units in Comunica, and buses and mediators form the _glue_ that ties them together and makes them interactable.
Actors are responsible for being able to accept certain messages
via the bus to which they are subscribed,
and for responding with an answer.
In order to avoid a single high-traffic bus for all message types which could cause performance issues,
separate buses exist for different message types.
[](#querying_relation-actor-bus) shows an example of how actors can be registered to buses.

<figure id="querying_relation-actor-bus">
<img src="querying/img/relation-actor-bus.svg" alt="[relation between actors and buses]" class="figure-small">
<figcaption markdown="block">
An example of two different buses each having two subscribed actors.
The left bus has different actors for parsing triples in a certain RDF serialization to triple objects.
The right bus has actors that join query bindings streams together in a certain way.
</figcaption>
</figure>

##### Mediators handle Actor Run and Test Phases

Each mediator is connected to a single bus, and its goal is to determine and invoke the *best* actor for a certain task.
The definition of '*best*' depends on the mediator, and different implementations can lead to different choices in different scenarios.
A mediator works in two phases: the _test_ phase and the _run_ phase.
The test phase is used to check under which conditions the action can be performed in each actor on the bus.
This phase must always come before the _run_ phase, and is used to select which actor is best suited to perform a certain task under certain conditions.
If such an actor is determined, the _run_ phase of a single actor is initiated.
This _run_ phase takes this same type of message, and requires to _effectively act_ on this message,
and return the result of this action.
[](#querying_run-test-phases) shows an example of a mediator invoking a run and test phase.

<figure id="querying_run-test-phases">
<img src="querying/img/run-test-phases.svg" alt="[mediators handle actor run and test phases]">
<figcaption markdown="block">
Example sequence diagram of a mediator that chooses the fastest actor
on a parse bus with two subscribed actors.
The first parser is very fast but requires a lot of memory,
while the second parser is slower, but requires less memory.
Which one is best, depends on the use case and is determined by the Mediator.
The mediator first calls the _tests_ of the actors for the given action,
and then _runs_ the action using the _best_ actor.
</figcaption>
</figure>

#### Modules

At the time of writing, Comunica consists of 79 different modules.
These consist of 13 buses, 3 mediator types, 57 actors and 6 other modules.
In this section, we will only discuss the most important actors and their interactions.

The main bus in Comunica is the _query operation_ bus, which consists of 19 different actors
that provide at least one possible implementation of the typical SPARQL operations such as quad patterns, basic graph patterns (BGPs), unions, projects, ...
These actors interact with each other using streams of _quad_ or _solution mappings_,
and act on a query plan expressed in [SPARQL algebra](cite:cites spec:sparqllang).

In order to enable heterogeneous sources to be queried in a federated way,
we allow a list of sources, annotated by type, to be passed when a query is initiated.
These sources are passed down through the chain of query operation actors,
until the quad pattern level is reached.
At this level, different actors exist for handling a single source of a certain type,
such as TPF interfaces, SPARQL endpoints, local or remote datadumps.
In the case of multiple sources, one actor exists that implements a [federation algorithm defined for TPF](cite:cites ldf),
but instead of federating over different TPF interfaces, it federates over different single-source quad pattern actors.

At the end of the pipeline, different actors are available for serializing the results of a query in different ways.
For instance, there are actors for serializing the results according to
the SPARQL [JSON](cite:cites spec:sparqljson) and [XML](cite:cites spec:sparqlxml) result specifications,
but actors with more visual and developer-friendly formats are available as well.
