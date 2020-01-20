In this chapter, we focus on the third challenge of this PhD: "The Web is highly *heterogeneous*".
In order to query over such a highly heterogeneous Web,
a query engine is needed that is able to handle various kinds of interfaces on the Web.
Furthermore, in order to handle these different kinds of interfaces *efficiently*,
various kinds of interface-specific algorithms must be supported.
For example, if an interface exposes a triple pattern index,
then the query should be able to detect and exploit this index to improve the efficiency when evaluating triple pattern queries.

The different kinds of Web interfaces,
and the large number of different querying algorithms that can be used with them
requires an intelligent query engine that detect these interfaces and apply these algorithms.
Our work in this chapter handles this problem by introducing a highly *flexible* and *modular* query engine platform *Comunica*.
Comunica has been designed in such a way that support for new interfaces and query algorithms can be developed *independently* as separate modules,
and these modules can then be *plugged* into Comunica when they are needed.
This engine simplifies the research and development of new query interfaces and algorithms,
as new techniques can be tested immediately in conjunction with other already existing interfaces and algorithms.

This chapter introduces a system architecture.
Unlike previous chapters were the goal was to research new methods,
the goal of this chapter is to introduce a new architecture.
While this work required research to determine a suitable architecture,
no novel methods were introduced.
As such, no research question was applicable here.
