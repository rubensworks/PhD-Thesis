### Implementation
{:#querying_implementation}

Comunica is implemented in TypeScript/JavaScript as a collection of Node modules, which are able to run in Web browsers using native Web technologies.
Comunica is available under an open license on [GitHub](https://zenodo.org/record/1202509#.Wq9GZhNuaHo){:.mandatory}
and on the [NPM package manager](https://www.npmjs.com/org/comunica){:.mandatory}.
The 79 Comunica modules are tested thoroughly, with more than 1,200 unit tests reaching a test coverage of 100%.
In order to be compatible with existing JavaScript RDF libraries,
Comunica follows the JavaScript API specification by the [RDFJS community group](https://www.w3.org/community/rdfjs/){:.mandatory},
and will [actively be further aligned](https://www.w3.org/community/rdfjs/2018/04/23/rdf-js-the-new-rdf-and-linked-data-javascript-library/) within this community.
In order to encourage collaboration within the community, we extensively use the [GitHub issue tracker](https://github.com/comunica/comunica/issues){:.mandatory}
for planned features, bugs and other issues.
Finally, we publish detailed [documentation](https://comunica.readthedocs.io){:.mandatory} for the usage and development of Comunica.

We provide a default Linked Data-based configuration file with all available actors for evaluating federated _SPARQL queries_ over heterogeneous sources.
This allows SPARQL queries to be evaluated using a command-line tool,
from a Web service implementing the [SPARQL protocol](cite:cites spec:sparqlprot),
within a JavaScript application,
or within the browser.
We fully implemented [SPARQL 1.0](cite:cites spec:sparqllang1) and a subset of [SPARQL 1.1](cite:cites spec:sparqllang) at the time of writing.
In future work, we intend to implement additional actors for supporting SPARQL 1.1 completely.

Comunica currently supports querying over the following types of _heterogeneous datasources and interfaces_:

* [Triple Pattern Fragments interfaces](cite:cites ldf)
* Quad Pattern Fragments interfaces ([an experimental extension of TPF with a fourth graph element](https://github.com/LinkedDataFragments/Server.js/tree/feature-qpf-latest){:.mandatory})
* [SPARQL endpoints](cite:cites spec:sparqlprot)
* Local and remote dataset dumps in RDF serializations.
* [HDT datasets](cite:cites hdt)
* [Versioned OSTRICH datasets](cite:cites ostrich)

In order to demonstrate Comunica's ability to evaluate _federated_ query evaluation over _heterogeneous_ sources,
the following guide shows how you can [try this out in Comunica yourself](https://gist.github.com/rubensworks/34bb69fa6c83176bce60a5e8a25051e8){:.mandatory}.

Support for new algorithms, query operators and interfaces can be implemented in an external module,
without having to create a custom fork of the engine.
The module can then be _plugged_ into existing or new engines that are identified by
[RDF configuration files](https://github.com/comunica/comunica/blob/master/packages/actor-init-sparql/config/config-default.json){:.mandatory}.

In the future, we will also look into adding support for other interfaces such as
[brTPF](cite:cites brtpf) for more efficient join operations
and [VTPF](cite:cites vtpf) for queries over versioned datasets.
