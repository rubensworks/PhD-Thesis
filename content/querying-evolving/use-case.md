### Use Case
{:#querying-evolving_use-case}

A&nbsp;guiding use case, based on public transport, will be referred to in the remainder of this paper.
When public transport route planning applications return dynamic data,
they can account for factors such as train delays
as part of a continuously updating route plan.
In this use case, different clients need to obtain all train departure information for a certain station.
This requires the following concepts:

* **Departure** (*static*): Unique IRI for the departure of a certain train.
* **Headsign** (*static*): The label of the train showing its destination.
* **Departure Time** (*static*): The *scheduled* departure time of the train.
* **Route Label** (*static*): The identifier for the train and its route.
* **Delay** (*dynamic*): The delay of the train, which can increase through time.
* **Platform** (*dynamic*): The platform number of the station at which the train will depart, which can be changed through time if delays occur.

[](#querying-evolving_listing:ta:originaltriples) shows example data in this model.
The SPARQL query in [](#querying-evolving_listing:usecase:basicquery)
can retrieve all information using this basic data model.

<figure id="querying-evolving_listing:ta:originaltriples" class="listing">
````/querying-evolving/code/ta-originaltriples.turtle````
<figcaption markdown="block">
Train information with static time information according to the basic data model.
</figcaption>
</figure>

<figure id="querying-evolving_listing:usecase:basicquery" class="listing">
````/querying-evolving/code/usecase-basicquery.sparql````
<figcaption markdown="block">
The basic SPARQL query for retrieving all upcoming train departure information in a certain station.
The two first triple patterns are dynamic, the last three are static.
</figcaption>
</figure>
