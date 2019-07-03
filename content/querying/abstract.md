### Abstract
{:#querying_abstract .no-label-increment}

<!-- Context      -->
Query evaluation over Linked Data sources has become a complex story,
given the multitude of algorithms and techniques
for single- and multi-source querying,
as well as the heterogeneity of Web interfaces
through which data is published online.
<!-- Need         -->
Today's query processors are insufficiently adaptable
to test multiple query engine aspects in combination,
such as evaluating the performance of a certain join algorithm
over a federation of heterogeneous interfaces.
The Semantic Web research community is in need of a flexible query engine
that allows plugging in new components
such as different algorithms,
new or experimental SPARQL features,
and support for new Web interfaces.
<!-- Task         -->
We designed and developed a Web-friendly and modular meta query engine
called _Comunica_
that meets these specifications.
<!-- Object       -->
In this article,
we introduce this query engine
and explain the architectural choices behind its design.
<!-- Findings     -->
We show how its modular nature makes it an ideal research platform
for investigating new kinds of Linked Data interfaces and querying algorithms.
<!-- Conclusion   -->
Comunica facilitates the development, testing, and evaluation
of new query processing capabilities,
both in isolation and in combination with others.
<!-- Perspectives -->
