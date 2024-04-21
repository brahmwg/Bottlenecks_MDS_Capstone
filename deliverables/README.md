In this section we have desirable deliverables for the MDS Capstone project.

Ultimately, our goal is to help you produce deliverables that are maximally valuable to your portfolios, as well as maximally valuable to our researchers. 

## Deliverables

Depending on the individual interests of the team members, we have a list of potential deliverables which collectively contribute to the Survival Analysis System for Salmon in the Salish Sea.

We recommend first reviewing the documentation, watching the videos, and familiarizing yourselves with our existing system. 

- We suggest for the hackathon, that you try to solve as many of the queries listed in the Query Catalogue as possible. This will help you become familiar with the data we have, as well as produce reusable queries for our researchers to refer to. Some assumptions may need to be made, or consultations with our researchers to clarify things, so please take time to review it carefully. Strong SQL skills will be needed for these, and queries can be run through our interface MarineScience.info .

- For team members interested in gaining experience with software development and containerized applications, we suggest exploring the Data Collection App deliverable. For this, we thought to use ODK, which is a popular open source data collection system. It can be used for our Pinniped project beginning soon (which is related to the predation component of the survival analysis system), but can also be used for all other data collection surveys. Furthermore, ODK offers official docker compose YAML files which can be used to integrate with our established system which also uses docker compose. Of course, it is unrealistic to expect that we could use this data collection system to collect enough data to be used for the analysis during the short time frame of the capstone. By completing this deliverable, students can claim experience with implementing containerized applications using docker compose for the purposes of data collection using open source software. 

- Another potential deliverable is related to data modelling. We have worked on developing an ERD to build a normalized data model to help impose constraints to improve data integrity. However, due to the extensive data cleaning required by the historical data, we have yet to implement this data model. As you can see, the ODS schema contains tables of data in the same state as they were collected. A potential deliverable would be for students to design/implement a normalized data model (can be based on our ERD) and/or design/implement a dimensional model. By completing this deliverable, students can claim they've gained experience with data modelling on research data.

- In line with the statistical experience you've gained over the course of your degree, we have a few deliverables related to building predictive models. See the outmigration timing model deliverable and species prediction models listed under the deliverables section. These may required integrating data from external sources, you can use the upload data feature to add such data to the staging schema. Furthermore, see the R dashboard as an example of the type of products our researchers have produced. Building similar data products would be valuable, and they can be built within our interface MarineScience.info using charts and dashboards.


