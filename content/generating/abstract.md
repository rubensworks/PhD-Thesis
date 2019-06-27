### Abstract
{:#generating_abstract}

<!--context-->
When benchmarking RDF data management systems such as public transport route planners,
system evaluation needs to happen under various realistic circumstances,
which requires a wide range of datasets with different properties.
Real-world datasets are almost ideal, as they offer these realistic circumstances,
but they are often hard to obtain and inflexible for testing.
For these reasons, synthetic dataset generators are typically preferred
over real-world datasets due to their intrinsic flexibility.
Unfortunately, many synthetic dataset that are generated within benchmarks are insufficiently realistic,
raising questions about the generalizability of benchmark results to real-world scenarios.
<!--need-->
In order to benchmark geospatial and temporal RDF data management systems
such as route planners
with sufficient external validity and depth,
<!--task-->
we designed PoDiGG,
a highly configurable generation algorithm for synthetic public transport datasets
with realistic geospatial and temporal characteristics
comparable to those of their real-world variants.
The algorithm is inspired by real-world public transit network design
and scheduling methodologies.
<!--object-->
This article discusses the design and implementation of PoDiGG
and validates the properties of its generated datasets.
<!--findings-->
Our findings show that the generator achieves a sufficient level of realism,
based on the existing coherence metric and new metrics we introduce specifically for the public transport domain.
<!--conclusions-->
Thereby, PoDiGG
provides a flexible foundation for benchmarking RDF data management systems with geospatial and temporal data.
