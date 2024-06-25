# Pipeline Orchestration with PL/Python and cron

## 0. Objective

ETL (Extract, Transform, Load) pipelines are important for managing and optimizing workflows. These pipelines make the process of collecting data more streamlined, transforming it, and loading it into a model, or another database. This automation makes sure there is data consistency, accuracy, and reliability, which are crucial for reproduceability. ETL pipelines also enhance efficiency by reducing the need for manual data handling; in other words saving time and minimizing human intervention. For this case, using PL/Python for scripting, and execution, and cron for orchestration, it makes the project more cohesive, just getting the necessary information a few clicks away, without the need for human intervention.

## 1. Folder Structure
```
- outmigration
  |- outmigration_process.sql 
  |- outmigration_predict.sql
- species_prediction
  |- species_process.sql
  |- species_predict.sql

```
Within this folder, users will find a few sub-folders as described in the table below. 
| Folder Name | Stored File Formats | Description |
| --- | --- | --- |
| outmigration | .sql | This directory contains the pipeline scripts to run the Outmigration model. This pipeline shall only be executed in the Strait of Georgia database, as it was designed for that purpose. |
| species_prediction | .sql | This directory contains the pipeline scripts to run the Species Prediction models. This pipeline shall only be executed in the Strait of Georgia database, as it was designed for that purpose. |

## 2. Installation

## Steps

#### 2.1 Create a Dockerfile:
```dockerfile
FROM postgres:latest

RUN apt-get update && apt-get install -y \
    postgresql-plpython3-$PG_MAJOR

ENV LANG en_US.utf8

EXPOSE 5432
```

#### 2.2 Build the Docker image:
```sh
docker build -t my_postgres_plpython .
```

#### 2.3 Run the Docker container:
```sh
docker run --name my_postgres_plpython_container -e POSTGRES_PASSWORD=mysecretpassword -d my_postgres_plpython
```

#### 2.4 Connect to the PostgreSQL container:
You can use pgAdmin4 or any other PostgreSQL client. If using pgAdmin4:
- Open pgAdmin4.
- Create a new server registration with the following details:
    - **Host name/address:** `localhost`
    - **Port:** `5432`
    - **Username:** `postgres`
    - **Password:** `mysecretpassword`

#### 2.5 Enable PL/Python extension:
Once connected to the PostgreSQL database, enable the PL/Python extension:
```sql
CREATE EXTENSION plpython3u;
 ```

#### 2.6 Create and run a PL/Python script:
You can now create and execute PL/Python functions in your PostgreSQL database.



## 3. Running Scripts
### 3.1 Outmigration
To run the Outmigration pipeline, you should run the `outmigration_process.sql` script in pgAdmin4. This SQL script will store the output data into the staging table `staging.outmigration`. 

After having the `staging.outmigration` table populated with data, you should run the `outmigration_predict.sql` script in pgAdmin4. This SQL script will print out the predicted start and peak date for the salmon outmigration in a plain text file called `outmigration_dates.txt`.


### 3.2 Species Prediction
To run the Species Prediction pipeline, you should run the `species_process.sql` script in pgAdmin4. This SQL script will store the output data into the staging table `staging.species`. 

After having the `staging.species` table populated with data, you should run the `species_predict.sql` script in pgAdmin4. This SQL script will populate the table `results.species`, where you will be able to find the resulting predictions from the voting classifiers.

### 3.3 Alternative ways of running the pipeline

Alternatively, this can be automated with a simple cron script.

## 4. Documentation
All the relevant documentation can be found in their respective scripts files. This is done in order to avoid clutter and facilitate debugging.
