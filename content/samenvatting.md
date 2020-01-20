## Samenvatting
{:#samenvatting}

In de afgelopen 30 jaar heeft het Web de manier waarop we informatie delen significant bevorderd,
wat geleid heeft tot grote transformaties van onze samenleving.
Origineel was informatie op het Web bedoeld voor mensen,
en machines hadden het moeilijk om deze informatie te verwerken op dezelfde manier als mensen.
Dit hinderde *intelligente assistenten* om bepaalde taken autonoom uit te voeren,
zoals bijvoorbeeld alle winkels vinden die een bepaald product verkopen in jouw huidige omgeving,
of bepalen wanneer het tijd is om te vertrekken om een vlucht te halen gebaseerd op de huidige verkeerssituatie en het weer.
Om deze intelligente assistenten mogelijk te maken hebben onderzoekers gewerkt aan technologieën en standaarden
om het Web begrijpbaar te maken voor machines.
In de voorbije jaren worden *kennisgrafen* gebouwd op basis van deze technologieën
om intelligente assistenten zoals Siri en Google Assistant deze taken te kunnen laten uitvoeren.

Het meeste onderzoek in de context van kennisgrafen is gefocust op *statische* gegevens.
Er is echter een grote hoeveelheid *evoluerende* gegevens beschikbaar,
zoals verkeersdata van snelweg sensoren of continue hartslag metingen.
Er zit veel waarde vervat zit in evoluerende kennis
zoals bijvoorbeeld het bepalen van drukke dagelijkse momenten op de snelweg,
of meldingen sturen wanneer de hartslag te hoog blijft voor onverwacht lange perioden.
Daarom is het belangrijk om deze informatie *op te slaan* in *evoluerende kennisgrafen*,
en om deze *doorzoekbaar* te maken.

Net zoals het Web, worden kennisgrafen meer en meer *gecentraliseerd*,
wat betekent dat informatie meer en meer in de handen komt van enkele grote entiteiten.
Dit leidt tot een beperkte beschikbaarheid van informatie voor het publiek,
waardoor de democratische en *gedecentraliseerde* eigenschappen van het Web in het gedrang komen.
Gebeurtenissen in de afgelopen jaren hebben aangetoond dat de centralisatie van informatie op deze schaal problematisch is,
aangezien het leidt tot problemen zoals censuur en manipulatie van informatie.
Om deze redenen is er een voortgaande inspanning om het Web *opnieuw te decentraliseren*,
en om het Web opnieuw een democratisch platform te maken door de macht terug te geven aan de mensen.
Aldus is decentralisatie en democratisering van informatie op het Web in de vorm van kennisgrafen een onderliggende focus van mijn onderzoek.

Om het gebruik van *evoluerende kennisgrafen* te vergemakkelijken,
is **het doel van dit doctoraat om het mogelijk te maken om *evoluerende* kennisgrafen te *publiceren* en *bevragen* op het Web**.
Om dit onderwerp te onderzoeken focus ik op vier uitdagingen gerelateerd aan dit onderwerp.
Ten eerste, om systemen die evoluerende kennisgrafen beheren te evalueren,
kijk ik naar de *generatie van evoluerende gegevens*.
Ten tweede onderzoek ik manieren om *evoluerende gegevens op te slaan*,
zodat gegevens efficiënt op het Web gepubliceerd en bevraagd kunnen worden.
Ten derde ontwerp ik een flexibel systeem om verschillende soorten gegevens te bevragen op het *Web*.
Tot slot onderzoek ik manieren om *evoluerende gegevens te publiceren en bevragen op het Web*.
In de context van dit doctoraat ga ik uit van traag evoluerende kennisgrafen die veranderen met een periodiciteit in de orde van minuten of trager,
omdat snellere periodiciteiten zoals relevant binnen stream processing beduidend andere technische vereisten nodig hebben.
Hierna zal ik de vier uitdagingen in meer detail uitleggen.

Om op een degelijke manier systemen te evalueren die evoluerende kennisgrafen beheren,
is het nodig om eerst evoluerende kennisgrafen te *hebben* om deze systemen mee te testen.
Aangezien bestaande evoluerende kennisgrafen beperkt zijn tot specifieke groottes,
zijn deze niet geschikt voor de noden van uitgebreide systeemevaluaties
waar configureerbare groottes van evoluerende kennisgrafen nodig zijn.
Dit is waarom de eerste uitdaging focust op de generatie van evoluerende gegevens, als een vereiste voor de volgende uitdagingen.
Concreet ontwerp ik een algoritme om synthetische datasets over het openbaar vervoer te genereren,
gebaseerd op populatie distributies als invoer.
Dit algoritme is geïmplementeerd en geëvalueerd in termen van realiteit en prestatie.
Resultaten tonen aan dat dit algoritme nuttig is voor de evaluatie van systemen die evoluerende kennisgrafen beheren,
met de garantie dat datasets voldoende representatief zijn ten opzichte van de echte wereld.

De tweede uitdaging focust op het onderzoek van een Web-vriendelijke afweging tussen opslagruimte en opzoek efficiëntie
voor evoluerende kennisgrafen.
Hiervoor ontwierp ik een opslagtechniek die in staat is om evoluerende gegevens te indexeren,
en samenhorige algoritmes werden ontwikkeld voor het doorzoeken van evoluerende gegevens op een efficiënte manier.
Deze index is gebaseerd op een hybride van verschillende soorten opslagtechnieken,
om verschillende temporele toegangspatronen efficiënt te maken.
De zoekalgoritmen ondersteunen *startafstanden* en *limieten*,
om willekeurige toegang tot deelverzamelingen van zoekresultaten mogelijk te maken,
wat belangrijk is voor een Web-vriendelijke zoek toegang.
Gebaseerd op een implementatie van deze opslagtechniek en zoekalgoritmen,
tonen experimentele resultaten aan dat dit systeem er in slaagt om een afweging te bereiken tussen opslagruimte en opzoek efficiëntie
die waardevol is voor het plaatsen van evoluerende kennisgrafen op het Web.
Concreet worden zoektijden gereduceerd ten koste van een toename in opslagruimte.
Deze kost is acceptabel aangezien opslag meestal vrij goedkoop is.

In de derde uitdaging wordt de *heterogeniteit* van het Web onderzocht.
Concreet ontwierp ik een zoekmachine (Comunica) die in staat is om te zoeken over verschillende soorten Web toegangen,
gebaseerd op verschillende zoekalgoritmen.
De zoekmachine is ontworpen op een modulaire manier,
zodat nieuwe soorten Web toegangen en algoritmen ontwikkeld en ingeplugd kunnen worden op een flexibele manier.
Dit maakt het mogelijk om verschillende Web toegangen en algoritmen op een eerlijke manier met elkaar te vergelijken,
wat dit een nuttig onderzoeksplatform maakt.

Tot slot verbindt de laatste uitdaging alle voorgaande uitdagingen met elkaar,
en focust op de publicatie van evoluerende gegevens op het Web via een doorzoekbare toegang.
Concreet introduceerde ik een doorzoekbare toegang voor evoluerende gegevens,
en een algoritme aan de client-zijde voor de continue bevraging over deze toegang op een herhalende manier.
Dit wordt gedaan door evoluerende gegevens te annoteren met bepaalde vervaltijden,
zo dat cliënten de optimale opzoekfrequentie kunnen bepalen,
en dat niet-vervallen gegevens kunnen worden hergebruikt wanneer meer vluchtige gegevens vervallen.
Resultaten tonen aan dat deze manier er in slaagt om een lagere belasting van de server te bereiken in vergelijking met een continue zoekmachine die volledig aan de server zijde draait,
ten koste van een toename in uitvoeringstijd en bandbreedte.

In deze vier uitdagingen werden technieken ontwikkeld om evoluerende kennisgrafen op te slaan en te bevragen
op een Web-vriendelijke manier.
Concreet kan dit worden gedaan door evoluerende kennisgrafen op te slaan in een hybride systeem van de tweede uitdaging.
Hier bovenop kan een Web toegang worden opgezet zoals deze ontworpen in de vierde uitdaging,
welke bevraagd kan worden van de klantzijde om server belasting te verlagen zoals gedaan wordt in uitdaging drie en vier.
Deze kunnen allemaal worden geëvalueerd met behulp van synthetische evoluerende kennisgrafen
die gegenereerd kunnen worden met het algoritme van de eerste uitdaging.

Alhoewel dit onderzoek een manier aantoont om evoluerende kennisgrafen op te slaan en te bevragen op het Web,
bestaan er verschillende afwegingen voor verschillende toepassingen.
Bijvoorbeeld, evoluerende kennisgrafen opslaan over kleine, traag evoluerende sensoren in het *internet der dingen*,
kunnen beperkt zijn in opslagruimte.
Aan de andere kant kunnen zeer vluchtige en gevoelige sensoren in nucleaire reactoren
een zeer grote opslagruimte vereisen.
In de toekomst zal meer onderzoek nodig zijn om technieken te onderzoeken
om het mogelijk maken om verschillende soorten evoluerende kennisgrafen op te slaan en te bevragen op het Web.
