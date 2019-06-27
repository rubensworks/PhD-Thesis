### Conclusions
{:#querying_conclusions}

In this work, we introduced Comunica as a highly modular meta engine for federated SPARQL query evaluation over heterogeneous interfaces.
Comunica is thereby the first system that accomplishes the Linked Data Fragments vision of a client that is able to query over heterogeneous interfaces.
Not only can Comunica be used as a client-side SPARQL engine, it can also be customized to become a more lightweight engine and perform more specific tasks,
such as for example only evaluating BGPs over Turtle files,
evaluating the efficiency of different join operators,
or even serve as a complete server-side SPARQL query endpoint that aggregates different datasources.
In future work, we will look into supporting supporting alternative (non-semantic) query languages as well, such as [GraphQL](cite:cites graphql).

If you are a Web researcher, then Comunica is the ideal research platform
for investigating new Linked Data publication interfaces,
and for experimenting with different query algorithms.
New modules can be implemented independently without having to fork existing codebases.
The modules can be combined with each other using an RDF-based configuration file
that can be instantiated into an actual engine through dependency injection.
However, the target audience is broader than just the research community.
As Comunica is built on Linked Data and Web technologies,
and is extensively documented and has a ready-to-use API,
developers of RDF-consuming (Web) applications can also make use of the platform.
In the future, we will continue [maintaining](https://github.com/comunica/comunica/wiki/Sustainability-Plan){:.mandatory}
and developing Comunica and intend to support and collaborate with future researchers on this platform.

The introduction of Comunica will trigger a _new generation of Web querying research_.
Due to its flexibility and modularity,
existing areas can be _combined_ and _evaluated_ in more detail,
and _new promising areas_ that remained covered so far will be exposed.
