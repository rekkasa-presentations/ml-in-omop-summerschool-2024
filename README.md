## Machine learning applications using OMOP-CDM

### General

Code for the running the analyses presented over the course and the deployment
of the presentation website.

For the purposes of the presentation we will use simulated data from the
[Synthea&trade;](https://synthetichealth.github.io/synthea/) project, mapped to
OMOP-CDM. We will consider the prediction of 60-day mortality in patients
hospitalized with pneumonia. Code for these analyses is located in `scripts`
directory, containing 3 files:

* *database_setup.R*: contains code for setting up the database, connecting to
it and generating the required cohorts.
* *single_model.R*: contains code for training a LASSO logistic regression
prediction model.
* *multiple_models.R*: contains code for training a LASSO logistic regression,
a random forest and a gradient boosting machine prediction models.

### Setup instructions

1. Clone the project repository. 
2. Inside the root of the project directory run 
`renv::restore()`. This should restore the R development environment used in the
presentation. 
3. Create `data` directory at the root of the project directory.
4. Download the simulated database from
[here](https://drive.google.com/file/d/1l5wq57fAslnoFR2umFQvVZbDiq5IK0UF/view?usp=sharing)
and unzip it inside `data`. This will result in a single file `duckdb` database.