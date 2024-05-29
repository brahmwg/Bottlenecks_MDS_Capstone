Date: 29-May-2024

Topic: Challenges and future of the imputation model

The goal of this model was to be able to impute data for missing species in the field table(or any table like microtroll). Unfortunately we cannot achive this model in our current capacity due to the following challenges:
1. Scarcity of data: in the field table we have 55 rows with species as 'NULL'. Among these the recorded features are watershed, river, site, method and local. Features like forklength, weight etc. which assist in identifying a fish, remains unrecorded as well. The only Identifier we have at the moment is tag_id.
2. Lack of data: In microtroll, we face the same issues, except tag_id too has not been recorded, this makes identification of the fish very chllenging

Given that we overcome these challenges in the future, we can definitely create an imputation model. For this we have written two pipelines (a decision tree and a deep-learning pipeline) both of which can be found in the "imputation_model/models" folder. These are two notebooks into wich the data can directly be injected.
A few lines of code have been commented out but they will be useful when you have data of different types and orders. The use of each line will be seen as comments near them.


