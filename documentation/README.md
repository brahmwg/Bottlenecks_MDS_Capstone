In this section we have various documentation to provide background on the Bottlenecks project.

![pg_dwh](https://github.com/brahmwg/Bottlenecks_MDS_Capstone/blob/c5421651e87bf63cd3fc00097091768e84100628/documentation/pg_dwh.png)

The 'pg_dwh' image depicts an overview of the structure of our database system.
Raw files are loaded into a schema called 'staging'. This acts as our loading zone / staging area. There you will find all of the raw files collected by the project, and some other files deemed relevant for inclusion. Most of the files are ingested with datatypes set to VARCHAR or TEXT, before they are processed and assigned proper datatypes and moved to the next layer.

Once the files from the staging schema are cleaned & processed, they are moved to the next layer which is a schema called 'ods'. This represents our operational data store. The name may be a bit of a misnomer, but essentially the files in ods are ready for operations. 

Next, views are created using the data tables in ods. These views represent our 'data marts' or analytical layer. They are designed for queries that are used for specific analytical purposes. Materialized views are employed in cases where updates are infrequent and to improve performance.


