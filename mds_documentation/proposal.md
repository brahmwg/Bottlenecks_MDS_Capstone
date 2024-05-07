# Survival analysis of salmon in the Salish sea
> **Team members**: Jenny Lee, Arturo Rey, Rafe Chang, Riya Eliza

## Executive summary
Our collaboration with the Pacific Salmon Foundation on the Bottleneck project will yield comprehensive visual analysis tools and advanced statistical and machine learning models, directly enhancing biologists' ability to understand salmon survival trends. Leveraging techniques from the Master of Data Science program, we aim to deliver impactful solutions for informed ecological study.

## Introduction
Salmons are critical to the ecosystem as they are food to 137 species(Rahr), such as grizzly bears. In British Columbia, there are over 9,000 distinct salmon populations (Pacific Salmon Foundation). But due to climate change and industrial development in the past 150 years, the population of Pacific salmon in BC had declined and their habitats had been facing unprecedented pressures. 

Pacific Salmon Foundation is a non-profit organization, the organization’s mission is to guide the sustainable future of Pacific salmon and its habitat. The organization had a wide range of work such as community investments and salmon health. As a part of the organization’s effort towards marine sciences, the Bottlenecks to Survival Projects investigate the survival bottlenecks, which refers when a population size is reduced for at least one ("Understanding Evolution"), for salmon and steelhead throughout the Salish sea and southern BC regions. 

The data for this project consists of tagging fishes with PIT tags at hatcheries and in the field, and the encounter of fishes and PIT antenna array or with captures.   

## Deliverables
### 1. Dashboard - `Fork length` vs. `Survivability`
To effectively communicate our data and analysis findings, we are designing and creating an interactive platform where our business partners can engage with graphical representations (graphs) and provided with concise summaries. Our goal here is to create visual tools that make it simple to see how changes in salmon fork lengths relate to their chances of survival. We will be using the visualization techniques and skills we learned from our previous courses to build interactive dashboards for this deliverable.

We will be creating this dashboard in the SuperSet interface the partners have provided in order to mantain all the information in one place.

### 2. Bayesian modelling
As a crucial component of our project, we will be involved in enhancing a survival analysis model utilizing Cormack-Jolly-Seber (CJS) Bayesian modeling techniques. This model is widely used in ecological research, for predicting changes in animal populations. Utilizing data gathered since 2021, the Pacific Salmon Foundation collected information pertaining to the posterior parameters of the Bayesian model. For prior distribution used in Bayesian modeling, telemetry data collected from previous researches are used.

### 3. Species prediction model
The goal of this model is to help fill information that was missed out during manual data collection, i.e; an imputation model.This model will be a supervised machine learning model using a decision tree. The labels for this model would be the different kinds of fishes found in the salish sea. Another output of this model is the confidence percentage for each of the predictions. This will help scientists decide whether they want to accept or reject the prediction. An interactive dash app will be created to take user inputs and view results of the prediction.

### 4. Outmigration model
Our goal with this model is to forecast when Coho and Chinook salmon will migrate from freshwater habitats. To achieve this, we will analyze tagging, detection, and site temperature data. Initially, we will look for trends, seasonality, and cyclicity in the data. If we find any, we will use time series modeling techniques. Otherwise, we will utilize machine learning for predictive modeling. Our partners have emphasized the importance of precise results, so we will prioritize achieving high accuracy rates based on a chosen evaluation metric.

## Pipeline
To ensure the continual updating of dashboards and models, it is important to establish a systematic workflow orchestration mechanism that executes at predefined schedules. This basically means the creation of a pipeline, which serves as the central concept for managing these processes. While numerous tools are available for this purpose, our partner has specifically requested the utilization of Apache Airflow. Apache Airflow is an open-source tool to programmatically author, schedule, and monitor workflows. It leverages directed acyclic graph (DAG) representation to facilitate user interaction and visually depict pipeline workflows.  

The implementation of the pipeline will follow the ETL (Extract, Transform, Load) principle. This involves extracting data from the Strait of Georgia Database, performing transformation operations using a Python script, and subsequently loading the processed data into cleaned tables within the same database. The models and dashboards will then retrieve information from these tables. The pipeline's operational flow is outlined in the following diagram:

![Pipeline](img/pipeline.png)

## Stretch goals
As previously mentioned, our primary efforts will be directed towards refining survival analysis modeling and developing two machine learning models. With these milestones accomplished, we are shifting our attention to stretch goals—additional objectives that may extend beyond the capstone period. Our stretch goals encompass the creation of an additional interactive dashboard; the purpose of this dashboard is to visualize the prediction rate of predators by herons and sea owls over time.

Stretch goals are aimed at maximizing progress within the remaining time frame, without a strict commitment to completing the work by the end of the capstone period. Our objective is to deliver comprehensive documentation alongside the primary deliverables, ensuring that the work can be seamlessly transitioned to other professionals for further development after the capstone period.

## Timeline
- Week 1: Deliver SQL queries
- Week 2: Understand Survival analysis paper and re-defining requirements, work on species prediction and outmigration models
- Week 3: Start working on survival analysis model, distribute the work, assign each section of the modelling to a team member 
- Week 4: Rest will be done when we meet with stakeholders
- Week 5
- Week 6
- Week 7
<br>This section will be further modified after we hold a meeting with our partners to discuss more about CJS Bayesian modeling. 

## Works Cited
- “Home.” Understanding Evolution, evolution.berkeley.edu/bottlenecks-and-founder-effects/. Accessed 7 May 2024.
- Rahr, Guido. “Why Protect Salmon.” Wild Salmon Center, 7 Nov. 2023, wildsalmoncenter.org/why-protect-salmon/.
- “State of Salmon.” Pacific Salmon Foundation, 13 Apr. 2022, psf.ca/salmon/. 
