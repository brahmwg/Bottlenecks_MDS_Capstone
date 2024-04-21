In this section we have various documentation to provide background on the Bottlenecks project.

## Videos

[![Bottlenecks to Survival](http://img.youtube.com/vi/5cH5wXQhCIc/0.jpg)](https://www.youtube.com/watch?v=5cH5wXQhCIc)



## Overview of the Bottlenecks Database System

![pg_dwh](https://github.com/brahmwg/Bottlenecks_MDS_Capstone/blob/c5421651e87bf63cd3fc00097091768e84100628/documentation/pg_dwh.png)

The 'pg_dwh' image depicts an overview of the structure of our database system. The name 'pg_dwh' refers to the Postgres Data Warehouse. In this data warehouse, data from field work (microtrolling, hatchery tagging, etc), genetic lab results, etc are stored to be integrated into the survival analyses. 

Raw files are loaded into a schema called 'staging'. This acts as our loading zone / staging area. There you will find all of the raw files collected by the project, and some other files deemed relevant for inclusion. Most of the files are ingested with datatypes set to VARCHAR or TEXT, before they are processed and assigned proper datatypes and moved to the next layer.

Once the files from the staging schema are cleaned & processed, they are moved to the next layer which is a schema called 'ods'. This represents our operational data store. The name may be a bit of a misnomer, but essentially the files in ods are ready for operations. 

Next, views are created using the data tables in ods. These views represent our 'data marts' or analytical layer. They are designed for queries that are used for specific analytical purposes. Materialized views are employed in cases where updates are infrequent and to improve performance.

## Overview of Software 

![software](https://github.com/brahmwg/Bottlenecks_MDS_Capstone/blob/643b8ed7d366c697386f7c375f70662c59fdf428/documentation/Bottlenecks%20-%20Process%20Flow%20Diagram.png)

The diagram above depicts a general overview of the proposed system for the Bottlenecks project. 

The server housed at UBC is a virtual machine with Ubuntu operating system. On it, docker compose is used to orchestrate the containerized applications, including postgres database, nginx proxy server, redis cache, apache superset etc.
