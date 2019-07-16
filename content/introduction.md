## Introduction
{:#introduction}

### The Web
{:#introduction-the-web}

#### Catalysts for Human Progress

Since the dawn of Mankind, biological evolution has shaped us into social animals.
The social capabilities of humans are however *much more evolved* than most other other species.
For example, [humans are one of the only animals that have clearly visible eye whites](https://pursuit.unimelb.edu.au/articles/why-we-show-the-whites-of-our-eyes).
This allows people to see what other people are looking at,
which simplifies *collaborative* tasks.
Furthermore, [*theory of mind*](https://www.sciencedirect.com/topics/neuroscience/theory-of-mind) —the ability to understand that others have different perspectives—, [is much more pronounced in humans than other animals](https://mitpress.universitypressscholarship.com/view/10.7551/mitpress/9780262016056.001.0001/upso-9780262016056), which also strengthens our ability to *collaborate*.
While our collaborative capabilities were initially limited to physical tasks,
the invention of *language* and *writing* allowed us to share *knowledge* with each other.

Methods for sharing knowledge are essential catalysts for human progress,
as shared knowledge allows larger groups of people to share goals
and accomplish tasks that would have otherwise been impossible.
Due to our *technological* progress,
the *bandwidth* of these methods for sharing knowledge is always increasing,
which is continuously increasing the rate of human and technological progress.

Throughout the last centuries, we saw three major revolutions in bandwidth.
First, the invention of the printing press in the 15th century
drastically increased rate at which books could be duplicated.
Secondly, there was the invention of radio and television in the 20th century,
As audio and video are cognitively less demanding than reading,
this lowered the barrier for spreading knowledge even further.
Third, we had the development of the internet near the end of the 20th century,
and the invention of the World Wide Web in 1989 on top of that,
which gave us a globally interlinked information space
that is fully *open* and *decentralized*, where anyone can say anything.
With the Web, bandwidth for knowledge sharing has become nearly unlimited,
as knowledge no longer has to go through a few large radio or tv stations,
but can now be shared over a virtually unlimited amount of Web pages,
which leads to a more *social* human species.

#### Impact of the Web

At the time of writing, the Web is 30 years old.
Considering [our species is believed to be 300,000 years old](http://humanorigins.si.edu/evidence/human-fossils/species/homo-sapiens),
this is just 0.01% of the time we have been around.
To put this in perspective in terms of a human life,
the Web would only be a baby of just under 3 days old,
assuming [a life expectancy of 80 years](https://countrymeters.info/en/Belgium).
This means that the Web *just* got started,
and it will take a long time for it to mature and achieve its full potential.

Even in this short amount of time,
the Web has already transformed our world in an unprecedented way.
Most importantly, it has given more than [56% of the global population](https://internetworldstats.com/stats.htm)
access to most of all human knowledge behind a finger's touch.
Secondly, *social media* has enabled people to communicate with anyone on the planet near-instantly,
and even with multiple people at the same time.
Furthermore, it has [impacted politics](https://ieeexplore.ieee.org/document/8267982)
and even [caused oppressive regimes to be overthrown](https://www.mic.com/articles/10642/twitter-revolution-how-the-arab-spring-was-helped-by-social-media).
Next to that, it is also significantly [disrupting businesses models that have been around since the industrial revolution, and creating new ones](https://stratechery.com/2015/airbnb-and-the-internet-revolution/).

#### Knowledge Graphs

Even though the Web has only existed for a brief window of time,
it already has made a significant impact on world for the better.
Yet, the goal of curiosity-driven researchers is to uncover
what the next steps are to improve the world *even more*.

In 2001, [Tim Berners-Lee shared his dream](cite:cites semanticweb) where machines
would be able to help out with our day-to-day tasks
by analyzing data on the Web and acting as *intelligent agents*.
Back then, the primary goal of the Web was to be *human-readable*.
In order for this dream to become a reality,
the Web had to become *machine-readable*.
This Web extension is typically referred to as the *Semantic Web*.

Now —almost twenty years later—, several standards and technologies have been developed to make this dream a reality,
[In 2013, more than four million Web domains are using these technologies](http://iswc2013.semanticweb.org/content/keynote-ramanathan-v-guha.html).
Using these Semantic Web technologies, so-called *Knowledge Graphs* are being constructed by many major companies world-wide,
such as [Google](https://developers.google.com/knowledge-graph/) and [Microsoft](https://developer.microsoft.com/en-us/graph/).
These Knowledge Graphs are being used to support tasks that were part of Tim Berners-Lee's original vision,
such as managing day-to-day tasks with the [Google Now assistant](https://www.google.com/intl/nl/landing/now/).

The standard for modeling Knowledge Graphs is the [Resource Description Framework (RDF)](cite:cites spec:rdf).
Fundamentally, it is based around the concept of *triples* that are used to make statements about things.
A triple is made up of a *subject*, *predicate* and *object*,
where the *subject* and *object* are resources, and the *predicate* denotes their relationship.
For example, [](#introduction-figure-triple) shows an example of a simple triple indicating the nationality of a person.
Multiple resources can combined with each other through multiple triples, which forms a *graph*.
[](#introduction-figure-graph) shows an example of such a graph, which contains *knowledge* about a person.
In order to look up information within such graphs, the [SPARQL query language](cite:cites spec:sparqllang)
was introduced as a standard.
Essentially, SPARQL allows RDF data to be looked up through combinations of *triple patterns*,
which are triples where any of its elements can be replace with *variables* such as `?name`.
For example, [](#introduction-code-sparql) contains a SPARQL query that find the names of all people that Alice knows.

<figure id="introduction-figure-triple">
<img src="img/triple.svg" alt="A triple" />
<figcaption markdown="block">
A triple indicating that Alice knows Bob.
</figcaption>
</figure>

<figure id="introduction-figure-graph">
<img src="img/graph.svg" alt="A knowledge graph" />
<figcaption markdown="block">
A small knowledge graph about Alice.
</figcaption>
</figure>

<figure id="introduction-code-sparql" class="listing">
````/code/query.sparql````
<figcaption markdown="block">
A simplified SPARQL query selecting the names of all people that Alice knows.
</figcaption>
</figure>

#### Evolving Knowledge Graphs

As one could expect, the Web is continuously evolving,
and it does to at an increasing rate.
For example, [Google is processing more than *40.000 search requests* *every second*](https://www.forbes.com/sites/bernardmarr/2018/05/21/how-much-data-do-we-create-every-day-the-mind-blowing-stats-everyone-should-read/#6907ae2460ba),
[*500 hours of video* are being uploaded to YouTube *every minute*](https://expandedramblings.com/index.php/youtube-statistics/),
and [more than *5.000* tweets are being sent *every seconds*](https://blog.hootsuite.com/twitter-statistics/).

Statistics like these show that significant research and engineering effort is needed to keep things on the Web working.
Specifically, work is needed to make it possible to
*store* all of this data as fast as possible,
and to make it *searchable* for *knowledge* as soon as possible.
As such, *evolving* Knowledge Graphs are the main focus of my research.

#### Decentralized Knowledge Graphs

The current *centralized* Knowledge Graphs do however not match well with the *decentralized* nature of the Web.
At the time of writing, these new Knowledge Graphs are in the hands of a few large corporations,
and intelligent agents on top of them are restricted to what these corporations allow them to do.
As people depend on the capabilities of these Knowledge Graphs,
large corporations gain significant control over the Web.
In the last couple of years, these centralized powers have proven to be problematic,
for example when [the flow of information is redirected to influence election results](https://fs.blog/2017/07/filter-bubbles/),
when [personal information is being misused](https://www.theguardian.com/technology/live/2018/apr/10/mark-zuckerberg-testimony-live-congress-facebook-cambridge-analytica),
or when [information is being censored due to idealogical differences](https://quillette.com/2019/06/06/against-big-tech-viewpoint-discrimination/).

For these reasons, there is a massive push for [*re-decentralizing the Web*](https://ruben.verborgh.org/articles/redecentralizing-the-web/),
where people regain *ownership* of their data.
Decentralization is however a technologically difficult thing.
As people do want ownership of their data, they do not want to give up their intelligent agents.
As such, this decentralization wave requires significant research effort to achieve the same capabilities as these *centralized* Knowledge Graphs,
which is why this is of important factor within my research.

### Research Question
{:#introduction-research-question}

The goal of my research is to allow people to *publish* and *find* knowledge
without having to depend on large centralized entities,
with a focus on knowledge that *evolves* over time.
This lead me to the following research question for my PhD:

> How to store and query evolving knowledge graphs on the Web?
{:#research-question .strong}

During my research, I focused on *four* main challenges
related to this research question:

1. **Experimentation requires *realistic* evolving data.**
    <br />
    In order to *evaluate* the performance of systems that handle *evolving* data,
    a flexible method for *obtaining* such data needs to be available.
2. **Indexing evolving data involves a *trade-off* between *storage size* and *lookup efficiency*.**
    <br />
    Indexing techniques are used to improve the efficiency of querying,
    but comes at the cost of increased storage.
    As such, it is important to find a good *balance* between the amount of *storage*,
    and the amount of *querying speedup*.
3. **The Web is highly *heterogeneous*.**
    <br />
    Before data can be queried from the Web,
    the different *formats* and *interfaces* in which data is available need to be considered and harmonized.
4. **Publishing *evolving* data via a *queryable interface* is costly.**
    <br />
    Centralized querying interfaces are hard to scale for an increasing number of concurrent clients,
    especially when the data that is being queried over is continuously evolving.
    New kinds of interfaces and querying algorithms are needed to cope with this scalability issue.

### Outline
{:#introduction-outline}

Corresponding to my four research challenges,
this thesis is based on the following four peer-reviewed publications:

* Ruben Taelman et al. [Generating Public Transport Data based on Population Distributions for RDF Benchmarking](https://www.rubensworks.net/raw/publications/2018/podigg.pdf).
    <br />In: *In Semantic Web Journal*. IOS Press, 2019.
* Ruben Taelman et al. [Triple Storage for Random-Access Versioned Querying of RDF Archives](https://rdfostrich.github.io/article-jws2018-ostrich/).
    <br />In: *Journal of Web Semantics*. Elsevier, 2019.
* Ruben Taelman et al. [Comunica: a Modular SPARQL Query Engine for the Web](https://comunica.github.io/Article-ISWC2018-Resource/).
    <br />In: *International Semantic Web Conference*. Springer, October 2018.
* Ruben Taelman et al. [Continuous Client-side Query Evaluation over Dynamic Linked Data](https://www.rubensworks.net/raw/publications/2016/Continuous_Client-Side_Query_Evaluation_over_Dynamic_Linked_Data.pdf).
    <br />In: *The Semantic Web: ESWC 2016 Satellite Events, Revised Selected Papers*. Springer, May 2016.


In [](#generating) a mimicking algorithm (*PoDiGG*) is introduced for generating *realistic* evolving public transport data,
so that it can be used to benchmark systems that work with evolving data.
This algorithm is based on established concepts for designing public transport networks,
and takes into account population distributions for simulating the flow of vehicles.
Next, in [](#storing), a storage architecture and querying algorithms are introduced
for managing evolving data.
It has been implemented as a system called *OSTRICH*,
and extensive experimentation shows that this systems introduces a useful trade-off between storage size and querying efficiency.
In [](#querying), A modular query engine is introduced called *Comunica* that is able to cope with the heterogeneity of date on the Web.
This engine has been designed to be highly flexible, so that it simplifies research within the query domain,
where new query algorithms can for example be developed in a separate module, and plugged into the engine without much effort.
In [](#querying-evolving), a publishing interface and accompanying querying algorithm (*TPF Query Streamer*) is introduced and evaluated
to enable evolving data with a low volatility to be published at a low cost, and queried continuously.
Finally, this work is concluded in [](#conclusions) and future research opportunities are discussed.