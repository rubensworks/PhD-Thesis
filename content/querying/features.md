### Requirement analysis
{:#querying_features}

In this section, we discuss the main requirements and features of the Comunica framework
as a research platform for SPARQL query evaluation.
Furthermore, we discuss each feature based on the availability in related work.
The main feature requirements of Comunica are the following:

SPARQL query evaluation
: The engine should be able to interpret, process and output results for SPARQL queries.

Modularity
: Different independent modules should contain the implementation of specific tasks, and they should be combinable in a flexible framework. The configurations should be describable in RDF.

Heterogeneous interfaces
: Different types of datasource interfaces should be supported, and it should be possible to add new types independently.

Federation
: The engine should support federated querying over different interfaces.

Web-based
: The engine should run in Web browsers using native Web technologies.

In [](#querying_features-comparison), we summarize the availability of these features in similar works.

<figure id="querying_features-comparison" class="table" markdown="1">

| Feature                  | TPF Client | ARQ    | RDFLib | rdflib.js | rdfstore-js | Comunica |
| ------------------------ |------------|--------|--------|-----------|-------------|----------|
| SPARQL                   | X(1)       | X      | X      | X(1)      | X(1)        | X(1)     |
| Modularity               |            |        |        |           |             | X        |
| Heterogeneous interfaces |            | X(2,3) | X(2,3) | X(3)      | X(3)        | X        |
| Federation               | X          | X(4)   | X(4)   |           |             | X        |
| Web-based                | X          |        |        | X         | X           | X        |

<figcaption markdown="block">
Comparison of the availability of the main features of Comunica in similar works.
(1) A subset of SPARQL 1.1 is implemented.
(2) Querying over SPARQL endpoints, other types require implementing an internal storage interface.
(3) Downloading of dumps.
(4) Federation only over SPARQL endpoints using the SERVICE keyword.
</figcaption>
</figure>

#### SPARQL query evaluation

The recommended way of querying within RDF data, is using the SPARQL query language.
All of the discussed frameworks support at least the parsing and execution of SPARQL queries, and reporting of results.

#### Modularity

Adding new functionality or changing certain operations in Comunica should require minimal to no changes to existing code.
Furthermore, the Comunica environment should be developer-friendly, including well documented APIs and auto-generation of stub code.
In order to take full advantage of the Linked Data stack, modules in Comunica must be describable, configurable and wireable in RDF.
By registering or excluding modules from a configuration file, the user is free to choose how heavy or lightweight the query engine will be.
Comunica's modular architecture will be explained in [](#querying_architecture).
ARQ, RDFLib, rdflib.js and rdfstore-js only support customization by implementing a custom query engine programmatically to handle operators.
They do not allow plugging in or out certain modules.

#### Heterogeneous interfaces

Due to the existence of different types of Linked Data Fragments for exposing Linked Datasets,
Comunica should support _heterogeneous_ interfaces types, including self-descriptive Linked Data interfaces such as TPF.
This TPF interface is the only interface that is supported by the TPF Client.
Additionally, Comunica should also enable querying over other sources,
such as SPARQL endpoints and data dumps in RDF serializations.
The existing SPARQL frameworks mostly support querying against SPARQL endpoints,
local graphs, and specific storage types using an internal storage adapter.

#### Federation

Next to the different type of Linked Data Fragments for exposing Linked Datasets,
data on the Web is typically spread over _different_ datasets, at different locations.
As mentioned in [](#querying_related-work), federated query processing is a way to query over the combination of such datasets,
without having to download the complete datasets and querying over them locally.
The TPF client supports federated query evaluation over its single supported interface type, i.e., TPF interfaces.
ARQ and RDFLib only support federation over SPARQL endpoints using the SERVICE keyword.
Comunica should enable _combined_ federated querying over its supported heterogeneous interfaces.

#### Web-based

Comunica must be built using native Web technologies, such as JavaScript and RDF configuration documents.
This allows Comunica to run in different kinds of environments, including Web browsers, local (JavaScript) runtime engines and command-line interfaces,
just like the TPF-client, rdflib.js and rdfstore-js.
ARQ and RDFLib are able to run in their language's runtime and via a command-line interface, but not from within Web browsers.
ARQ would be able to run in browsers using a custom Java applet, which is not a native Web technology.
