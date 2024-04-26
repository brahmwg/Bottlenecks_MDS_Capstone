In this section we have various documentation to provide background on the Bottlenecks project.

## Videos

To familiarize yourself with the operations and background of the Bottlenecks to Survival Project, we suggest you watch the following videos;

[![Bottlenecks to Survival](http://img.youtube.com/vi/5cH5wXQhCIc/0.jpg)](https://www.youtube.com/watch?v=5cH5wXQhCIc) [![Bottlenecks to Survival Volunteers](http://img.youtube.com/vi/PhlAyfypy1g/0.jpg)](https://www.youtube.com/watch?v=PhlAyfypy1g) [![Bottlenecks to Survival Volunteers Sam](http://img.youtube.com/vi/eFaBHc-2uxY/0.jpg)](https://www.youtube.com/watch?v=eFaBHc-2uxY) [![Bottlenecks to Survival Salish Sea](http://img.youtube.com/vi/Cgj9TjLB3-c/0.jpg)](https://www.youtube.com/watch?v=Cgj9TjLB3-c) [![Bottlenecks to Survival](http://img.youtube.com/vi/0AlQNyMOgcY/0.jpg)](https://www.youtube.com/watch?v=0AlQNyMOgcY) [![Bottlenecks to Survival](http://img.youtube.com/vi/ETfma2rYxic/0.jpg)](https://www.youtube.com/watch?v=ETfma2rYxic)


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

![documentation/pg_dwh.ods.schema.png](https://github.com/brahmwg/Bottlenecks_MDS_Capstone/blob/77c734480c06af29a7ff25033b56b5036e1c1b93/documentation/pg_dwh.ods.schema.png)

The diagram above depicts the ods schema, it's tables, attributes and how they relate to eachother. It is suggested that you review the [data dictionary](https://github.com/brahmwg/Bottlenecks_MDS_Capstone/blob/fce496db2ea3d2ac7bca254d409ad9d200cc7b43/documentation/data_dictionary_ods.csv)  to better understand each table and it's contents. 


