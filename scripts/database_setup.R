connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "duckdb", 
  server = "data/database-1M_filtered.duckdb"
)

connection <- DatabaseConnector::connect(
  connectionDetails = connectionDetails
)
DatabaseConnector::querySql(
  connection,
  "SELECT cohort_definition_id,count(*) FROM summerschool GROUP BY cohort_definition_id;")



# Hypertension
essentialHypertension <- Capr::cs(
  Capr::descendants(320128),
  name = "Essential hypertension"
)

sbp <- Capr::cs(3004249, name = "SBP")
dbp <- Capr::cs(3012888, name = "DBP")

hypertensionCohort <- Capr::cohort(
  entry = Capr::entry(
    Capr::conditionOccurrence(essentialHypertension),
    Capr::measurement(sbp, Capr::valueAsNumber(Capr::gte(130)), Capr::unit(8876)),
    Capr::measurement(dbp, Capr::valueAsNumber(Capr::gte(80)),  Capr::unit(8876))
  ),
  exit = Capr::exit(
    endStrategy = Capr::observationExit()
  )
)

# Acute myocardial infarction
myocardialInfarction <- Capr::cs(
  Capr::descendants(4329847),
  Capr::exclude(Capr::descendants(314666)),
  name = "Myocardial infarction"
)
inpatientOrEr <- Capr::cs(
  Capr::descendants(9201),
  Capr::descendants(262),
  name = "Inpatient or ER"
)
amiCohort <- Capr::cohort(
  entry = Capr::entry(
    Capr::conditionOccurrence(myocardialInfarction),
    additionalCriteria = Capr::withAll(
      Capr::atLeast(
        x = 1,
        query = Capr::visit(inpatientOrEr),
        aperture = Capr::duringInterval(
          Capr::eventStarts(-Inf, 0), 
          Capr::eventEnds(0, Inf)
        )
      )
    ),
    primaryCriteriaLimit = "All",
    qualifiedLimit = "All"
  ),
  attrition = Capr::attrition(
    "No prior AMI" = Capr::withAll(
      Capr::exactly(
        x = 0,
        query = Capr::conditionOccurrence(myocardialInfarction),
        aperture = Capr::duringInterval(Capr::eventStarts(-365, -1))
      )
    )
  ),
  exit = Capr::exit(
    endStrategy = Capr::fixedExit(index = "startDate", offsetDays = 1)
  )
)
cohortDefinitionSet <- Capr::makeCohortSet(hypertensionCohort, amiCohort)

cohortTableNames <- CohortGenerator::getCohortTableNames(cohortTable = "summerschool")

# Next create the tables on the database
CohortGenerator::createCohortTables(
  connectionDetails = connectionDetails,
  cohortTableNames = cohortTableNames,
  cohortDatabaseSchema = "main"
)

# Generate the cohort set
cohortsGenerated <- CohortGenerator::generateCohortSet(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = "main",
  cohortDatabaseSchema = "main",
  cohortTableNames = cohortTableNames,
  cohortDefinitionSet = cohortDefinitionSet
)
