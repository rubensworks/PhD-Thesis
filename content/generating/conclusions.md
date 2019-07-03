### Conclusions
{:#generating_conclusions}

In this article, we introduced a mimicking algorithm for public transport data,
based on steps that are used in real-world transit planning.
Our method splits this process into several sub-generators and uses population distributions of an area as input.
As part of this article, we introduced PoDiGG, a reusable framework that accepts a wide range of parameters to configure the generation algorithm.

Results show that the structuredness of generated datasets are similar to real public transport datasets.
Furthermore, we introduced several functions for measuring the realism of
synthetic public transport datasets compared to a gold standard on several levels, based on distance functions.
The realism was confirmed for different regions and transport types.
Finally, the execution times and memory usages were measured when increasing the most important parameters,
which showed a linear increase for each parameter, showing that the generator is able to scale to large dataset outputs.

The public transport mimicking algorithm we introduced, with PoDiGG and PoDiGG-LC as implementations,
is essential for properly benchmarking the efficiency and performance
of public transport route planning systems under a wide range of realistic, but synthetic circumstances.
Flexible configuration allows datasets of any size to be created
and various characteristics to be tweaked to achieve highly specialized datasets for testing specific use cases.
In general, our dataset generator can be used for the benchmarking of geospatial and temporal RDF data management systems,
and therefore lowers the barrier towards more efficient and performant systems.