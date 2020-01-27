# PhD Thesis

This is the source for my thesis for obtaining a PhD in Computer Science at Ghent University.

The published version at https://phd.rubensworks.net contains machine-readable information,
and can be queried by SPARQL query engines such as [Comunica](https://query.linkeddatafragments.org).
For example, query my [hypotheses](http://query.linkeddatafragments.org/#datasources=https%3A%2F%2Fphd.rubensworks.net%2F&query=%23%20All%20hypotheses%0APREFIX%20ls%3A%20%3Chttp%3A%2F%2Flinkedscience.org%2Flsc%2Fns%23%3E%0APREFIX%20schema%3A%20%3Chttp%3A%2F%2Fschema.org%2F%3E%0A%0ASELECT%20%3Ftest%20%3Fname%20WHERE%20%7B%0A%20%20%3Ftopic%20ls%3Atests%20%3Ftest.%0A%20%20%3Ftest%20schema%3Aname%20%3FnameRaw.%0A%0A%20%20%23%20Remove%20HTML%20tags%0A%20%20BIND(REPLACE(%3FnameRaw%2C%20%22%3C%5B%5E%3E%5D*%3E%22%2C%20%22%22%2C%20%22i%22)%20AS%20%3Fname)%0A%7D), [research questions](http://query.linkeddatafragments.org/#datasources=https%3A%2F%2Fphd.rubensworks.net%2F&query=%23%20All%20research%20questions%0APREFIX%20schema%3A%20%3Chttp%3A%2F%2Fschema.org%2F%3E%0A%0ASELECT%20%3Fquestion%20%3Fname%20WHERE%20%7B%0A%20%20%3Ftopic%20schema%3Aquestion%20%3Fquestion.%0A%20%20%3Fquestion%20schema%3Aname%20%3FnameRaw.%0A%0A%20%20%23%20Remove%20HTML%20tags%0A%20%20BIND(REPLACE(%3FnameRaw%2C%20%22%3C%5B%5E%3E%5D*%3E%22%2C%20%22%22%2C%20%22i%22)%20AS%20%3Fname)%0A%7D), or [cited articles](http://query.linkeddatafragments.org/#datasources=https%3A%2F%2Fphd.rubensworks.net%2F&query=%23%20All%20citations%0APREFIX%20schema%3A%20%3Chttp%3A%2F%2Fschema.org%2F%3E%0APREFIX%20cito%3A%20%3Chttp%3A%2F%2Fpurl.org%2Fspar%2Fcito%2F%3E%0A%0ASELECT%20%3Fcitation%20%3Fsection%20%3Farticle%20WHERE%20%7B%0A%20%20%3Fcitation%20schema%3Aname%20%3Fsection.%0A%20%20%3Fcitation%20cito%3Acites%20%3Farticle.%0A%7D).
More example queries: https://github.com/rubensworks/PhD-Thesis/tree/master/queries/

## Build
```
bundle install
bundle exec nanoc compile
```

## Development mode
```
bundle install
bundle exec guard
```

View on http://localhost:3000/
