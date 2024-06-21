# Bottlenecks_MDS_Capstone
Master of Data Science Capstone Project for Bottlenecks to Survival

Please review the documentation section for background info on the Bottlenecks Project.

Please review the Data Dictionary and schema to gain insight into the meaning behind many of the attributes of our tables in the database.

Please review the FAQ section for information on how to access our interface and query the database.

Please review the Deliverables section for examples of desirable deliverables the team would like from this capstone project.



<p align="center">
<img src="https://www.canadahelps.org/uploads/ik-images/charity/27040/pacific-salmon-foundation-fondation-du-saumon-du-pacifique-logo_thumbnail_en.png" alt="PSF" width="190"/>   <img src="https://www.survivalbottlenecks.ca/wp-content/uploads/2023/11/Regular_Verticle.png" alt="BCCF" width="200"/> </p>
 <p align="center">
<img src="https://www.survivalbottlenecks.ca/wp-content/uploads/2021/10/fisheries.png" alt="DFO" width="300"/>
<img src="https://www.survivalbottlenecks.ca/wp-content/uploads/2022/06/BCID-Domestic_H_pos_CMYK-600x171.png" alt="BC" width="200"/>
</p>

---
## Folder Structure
```
/Bottlenecks_MDS_Capstone
├── OutMigration_model
│   ├── data
│   ├── demo
│   ├── exploration
│   └── scripts
│       ├── outM_prediction.py
│       └──  outM_preprocessing.py
│
└── survival_analysis
    ├── data
    ├── notebooks
    ├── queries
    └── scripts
       ├── preprocessing.R
       └── survival_analysis_model.R
```

## Running Scripts Locally in Python
### List of Dependencies
To install all Python dependencies necessary for running the app locally, you can utilize the `environment.yml` file. This file contains a list of dependencies required for the project. You can install them using a package manager such as Conda. List of dependencies needed for this dashboard are:
```
name: mds_bottleneck
channels:
  - conda-forge
  - defaults
dependencies:
  - numpy
  - matplotlib
  - pandas
  - seaborn
  - scikit-learn
  - vl-convert-python
  - altair 
  - vegafusion  
  - vegafusion-python-embed  
  - vegafusion-jupyter
  - pytorch 
```
### Steps to Follow for Installing Dependencies

1. Open a terminal or command line on your local computer.
2. Navigate to the directory or folder containing the index.py file.
3. Run the following command below to install the dependencies.

```
conda env create -f environment_ml.yml
```

4. Activate the environment using `conda` as below.

```
conda activate mds_bottleneck
```

5. Follow `demo.ipynb` stored under the `outMigration_model` folder and `species_prediction_model` to run the scripts locally. 

## Running Scripts Locally in R
### Steps to Follow for Installing Dependencies
1. Open a terminal or command line on your local computer.
2. Navigate to the directory or folder containing the R script files.
3. Install dependencies using renv by running the following command:
<br> First, ensure renv is installed. If not, you can install it using:
```
install.packages("renv")
```
4. Initialize the renv environment and install dependencies to finish setting up `renv` environment with the following command:
```
Rscript -e 'renv::init()'
```
5. Follow the instructions in your R scripts (e.g., demo.R files) stored under `survival_analysis` folder to run the scripts locally.
<br> Make sure to navigate to the appropriate folder and run your R scripts as needed. For example:
```
Rscript outMigration_model/demo.R
```
