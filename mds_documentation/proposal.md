# Survival analysis of salmon in the Salish sea
> **Team members**: Jenny Lee, Arturo Rey, Rafe Chang, Riya Eliza

## Executive summary
Our collaboration with the Pacific Salmon Foundation on the Bottleneck project will yield comprehensive visual analysis tools and advanced statistical and machine learning models, directly enhancing biologists' ability to understand salmon survival trends. By leveraging techniques from the Master of Data Science program, we aim to gain deepeer understanding of salmon survival probability, considering factors like predation, body size, origin site, and others.

## Introduction
Salmons are critical to the ecosystem as they are food to 137 species(Rahr, 2023), such as grizzly bears. In British Columbia, there are over 9,000 distinct salmon populations ("State of Salmon", 2022). However, due to climate change and industrial development in the past 150 years, the population of Pacific salmon in BC has declined and their habitats have been facing unprecedented pressures. 

Pacific Salmon Foundation is a non-profit organization committed to guiding the sustainable future of Pacific salmon and its habitat. The organization has a wide range of work such as community investments and salmon health. As a part of the organization’s effort towards marine sciences, the Bottlenecks to Survival Projects investigate the survival bottlenecks, which refers to when a population size is reduced for at least one ("Understanding Evolution"), for salmon and steelhead throughout the Salish Sea and southern BC regions. 

The data for this project consists of tagging fishes with PIT tags at hatcheries and in the field, and the encounter of fishes and PIT antenna array or with captures. Using these data, we will build models and dashboards to better understand Pacific salmons' survival in the Salish Sea our business partners can engage with graphical representations (graphs) and provided with concise summaries. Our goal here is to create visual tools that make it simple to see how changes in salmon fork lengths relate to their chances of survival. We will be using the visualization techniques and skills we learned from our previous courses to build interactive dashboards for this deliverable, such as bar charts for categorical data, line or scatter plots for continuous data, and histograms for data distribution. This alongside filters for data slicing, will make an intuitive yet useful approach to visualize our data to the partners.

We will be creating this dashboard in the SuperSet interface the partners have provided in order to mantain all the information in the same place where the queries lie, so it's easy for the partners to alternate from query to dashboard.

### 2. Bayesian modelling
As a crucial component of our project, we will be involved in enhancing a survival analysis model utilizing Cormack-Jolly-Seber (CJS) Bayesian modeling techniques. This model is widely used in ecological research, for predicting changes in animal populations (Cormack, 1964; Jolly, 1965; Seber, 1965). Utilizing data gathered since 2021, the Pacific Salmon Foundation collected information pertaining to the posterior parameters of the Bayesian model. For prior distribution used in Bayesian modeling, telemetry data collected from previous researches are used.

We will explore various factors acting as confounders and employ blocking and stratification techniques to isolate these factors effectively. Additionally, to address the inherent limitations of Bayesian modeling in CJS models, especially its reliance on high fish recapture rates, we will investigate alternative statistical modeling approaches. Lastly, integrating real-world data into our models will enhance their accuracy and applicability, ensuring that our analyses reflect the complexities of the ecosystems under study.

### 3. Species prediction model
The goal of this model is to help fill information that was missed out during manual data collection, i.e; an imputation model.This model will be a supervised machine learning model using a decision tree. The labels for this model would be the different kinds of fishes found in the salish sea. Another output of this model is the confidence percentage for each of the predictions. This will help scientists decide whether they want to accept or reject the prediction. An interactive dash app will be created to take user inputs and view results of the prediction. The success criteria for this model will be the confidence of prediction being greater than a decided threshold (e.g: 75%).

### 4. Outmigration model
Our goal with this model is to forecast the outmigration dates for Steelhead, Coho, and Chinook salmon as they migrate from freshwater habitats. To achieve this, we will analyze tagging, detection, site flow, and site temperature data to predict outmigration timing. After observing seasonality in river flow data after conducting EDA, we will use time series modeling techniques. Because of the seasonality, we will use a seasonal autoregressive integrated moving average model (SARIMA). In this case, we are not considering cross-validation, but we will split the data into train and test data to test the accuracy, based on a chosen evaluation metric. Based on the model's performance, we might also utilize machine learning for predictive modeling. 

## Pipeline
To ensure the continual updating of dashboards and models, it is important to establish a systematic workflow orchestration mechanism that executes at predefined schedules. This basically means the creation of a pipeline, which serves as the central concept for managing these processes. While numerous tools are available for this purpose, our partner has specifically requested the utilization of Apache Airflow. Apache Airflow is an open-source tool to programmatically author, schedule, and monitor workflows. It leverages directed acyclic graph (DAG) representation to facilitate user interaction and visually depict pipeline workflows.  

The implementation of the pipeline will follow the ETL (Extract, Transform, Load) principle. This involves extracting data from the Strait of Georgia Database, performing transformation operations using a Python script, and subsequently loading the processed data into cleaned tables within the same database. The models and dashboards will then retrieve information from these tables. The pipeline's operational flow is outlined in the following diagram:

![Pipeline](img/pipeline.png)
Figure 1: Proposed data pipeline mockup

## Stretch goals
As previously mentioned, our primary efforts will be directed towards refining survival analysis modeling and developing two machine learning models. With these milestones accomplished, we are shifting our attention to stretch goals—additional objectives that may extend beyond the capstone period. Our stretch goals encompass the creation of an additional interactive dashboard; the purpose of this dashboard is to visualize the prediction rate of predators by herons and sea owls over time. This analysis will enable biologists to look into trends in predation and its correlation with salmon survival probability. To fulfill this objective, we will establish a foundational structure and develop a functional dashboard using Superset.

Stretch goals are aimed at maximizing progress within the remaining time frame, without a strict commitment to completing the work by the end of the capstone period. Our objective is to deliver comprehensive documentation alongside the primary deliverables, ensuring that the work can be seamlessly transitioned to other professionals for further development after the capstone period. All completed work will be thoroughly documented and stored in a GitHub repository for easy access and future reference.

## Timeline
- Week 1: Deliver SQL queries <br>
- Week 2: Understand Survival analysis paper and re-defining requirements, work on species prediction and outmigration models <br>
- Week 3: Fine-tuning species prediction and outmigration model, start working on survival analysis model, distribute the work, assign each section of the modelling to a team member <br>
- Week 4: Prioritize survival ananlysis model and coding. Review the outmigration and survival analysis model. <br>
- Week 5: Pipeline for survival analysis using original data in place of simulation data. <br>
- Week 6: Continue working on inferences for the survival analysis. <br>
- Week 7: Finalize the models and review them with the stakeholders. If we have time left, work on stretch goals.<br>

## Works Cited
- Cormack, R. M. ‘Estimates of Survival from the Sighting of Marked Animals’. Biometrika, vol. 51, no. 3/4, JSTOR, Dec. 1964, p. 429, https://doi.org10.2307/2334149.
- “Understanding Evolution", https://evolution.berkeley.edu/bottlenecks-and-founder-effects/. Accessed 7 May 2024.
- Jolly, G. M. ‘Explicit Estimates from Capture-Recapture Data with Both Death and Immigration-Stochastic Model’. Biometrika, vol. 52, no. 1–2, Oxford University Press (OUP), June 1965, pp. 225–247, https://doi.org10.1093/biomet/52.1-2.225.
- Rahr, Guido. “Why Protect Salmon.” Wild Salmon Center, 7 Nov. 2023, wildsalmoncenter.org/why-protect-salmon/.
- Seber, G. A. ‘A note on the multiple-recapture census’, Biometrika 52(1/2), 1965, 249–259.
- “State of Salmon.” Pacific Salmon Foundation, 13 Apr. 2022, psf.ca/salmon/. 
