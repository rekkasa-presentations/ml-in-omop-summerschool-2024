connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = "duckdb", 
  server = "data/database-1M_filtered.duckdb"
)

covariateSettings <- FeatureExtraction::createCovariateSettings(
  useDemographicsGender = TRUE,
  useDemographicsAge = TRUE,
  useConditionGroupEraLongTerm = TRUE,
  useConditionGroupEraAnyTimePrior = TRUE,
  useDrugGroupEraLongTerm = TRUE,
  useDrugGroupEraAnyTimePrior = TRUE,
  useVisitConceptCountLongTerm = TRUE,
  longTermStartDays = -365,
  endDays = -1
)

databaseDetails <- PatientLevelPrediction::createDatabaseDetails(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = "main",
  cohortDatabaseSchema = "main",
  cohortTable = "summerschool",
  targetId = 1,
  outcomeDatabaseSchema = "main",
  outcomeTable = "summerschool",
  outcomeIds = 2
)

restrictPlpDataSettings <- PatientLevelPrediction::createRestrictPlpDataSettings()

# plpData <- PatientLevelPrediction::getPlpData(
#   databaseDetails = databaseDetails, 
#   covariateSettings = covariateSettings, 
#   restrictPlpDataSettings = restrictPlpDataSettings
# )
# 
# PatientLevelPrediction::savePlpData(
#   plpData = plpData,
#   file = "data/plpData"
# )

plpData <- PatientLevelPrediction::loadPlpData("data/plpData")

populationSettings <- PatientLevelPrediction::createStudyPopulationSettings(
  washoutPeriod = 364,
  firstExposureOnly = FALSE,
  removeSubjectsWithPriorOutcome = TRUE,
  priorOutcomeLookback = 9999,
  riskWindowStart = 1,
  riskWindowEnd = 5*365, 
  minTimeAtRisk = 5*364,
  startAnchor = 'cohort start',
  endAnchor = 'cohort start',
  requireTimeAtRisk = TRUE,
  includeAllOutcomes = TRUE
)

splitSettings <- PatientLevelPrediction::createDefaultSplitSetting(
  trainFraction = 0.75,
  testFraction = 0.25,
  type = 'stratified',
  nfold = 2, 
  splitSeed = 1234
)

sampleSettings <- PatientLevelPrediction::createSampleSettings()

featureEngineeringSettings <- PatientLevelPrediction::createFeatureEngineeringSettings()

preprocessSettings <- PatientLevelPrediction::createPreprocessSettings(
  minFraction = .01,
  normalize = TRUE,
  removeRedundancy = TRUE
)


lrModel <- PatientLevelPrediction::setLassoLogisticRegression()


lrResults <- PatientLevelPrediction::runPlp(
  plpData = plpData,
  outcomeId = 2, 
  analysisId = 'singleDemo',
  analysisName = 'Demonstration of runPlp for training single PLP models',
  populationSettings = populationSettings, 
  splitSettings = splitSettings,
  sampleSettings = sampleSettings, 
  featureEngineeringSettings = featureEngineeringSettings, 
  preprocessSettings = preprocessSettings,
  modelSettings = lrModel,
  logSettings = PatientLevelPrediction::createLogSettings(), 
  executeSettings = PatientLevelPrediction::createExecuteSettings(
    runSplitData = T, 
    runSampleData = T, 
    runfeatureEngineering = T, 
    runPreprocessData = T, 
    runModelDevelopment = T, 
    runCovariateSummary = T
  ), 
  saveDirectory = file.path(getwd(), "results")
)