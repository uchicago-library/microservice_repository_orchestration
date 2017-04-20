This repository contains the necessary files to spin up the core microservices for an archival digital repository.

It relies on the following projects:

- [Archstor](https://github.com/bnbalsamo/archstor) for data storage
- [idnest](https://github.com/uchicago-library/idnest) for basic accession organization
- [qremis_api](https://github.com/bnbalsamo/qremis_api) for managing metadata records

The [accutil](https://github.com/bnbalsamo/qremis_accutil) is built to ingest files into the microservice systems.

To fire up a development rollout:

```
$ bash setup.sh && sudo docker-compose up
```
