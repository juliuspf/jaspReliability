
reliabilityUniDimFrequentist <- function(jaspResults, dataset, options) {


  dataset <- .readData(dataset, options)
  .checkErrors(dataset, options)

  if (length(options[["reverseScaledItems"]]) > 0L) {
    dataset <- .reverseScoreItems(dataset, options)
  }

  model <- .frequentistPreCalc(jaspResults, dataset, options)

  model[["itemDroppedCovs"]] <- .frequentistItemDroppedMats(jaspResults, dataset, options, model)
  model[["derivedOptions"]] <- .frequentistDerivedOptions(options)
  model[["omegaScale"]] <- .frequentistOmegaScale(jaspResults, dataset, options, model)
  model[["omegaItem"]] <- .frequentistOmegaItem(jaspResults, dataset, options, model)
  model[["alphaScale"]] <- .frequentistAlphaScale(jaspResults, dataset, options, model)
  model[["alphaItem"]] <- .frequentistAlphaItem(jaspResults, dataset, options, model)
  model[["lambda2Scale"]] <- .frequentistLambda2Scale(jaspResults, dataset, options, model)
  model[["lambda2Item"]] <- .frequentistLambda2Item(jaspResults, dataset, options, model)
  model[["lambda6Scale"]] <- .frequentistLambda6Scale(jaspResults, dataset, options, model)
  model[["lambda6Item"]] <- .frequentistLambda6Item(jaspResults, dataset, options, model)
  model[["glbScale"]] <- .frequentistGlbScale(jaspResults, dataset, options, model)
  model[["glbItem"]] <- .frequentistGlbItem(jaspResults, dataset, options, model)

  model[["average"]] <- .frequentistAverageCor(jaspResults, dataset, options, model)
  model[["mean"]] <- .frequentistMean(jaspResults, dataset, options, model)
  model[["sd"]] <- .frequentistStdDev(jaspResults, dataset, options, model)
  model[["itemRestCor"]] <- .frequentistItemRestCor(jaspResults, dataset, options, model)
  model[["itemMean"]] <- .frequentistItemMean(jaspResults, dataset, options, model)
  model[["itemSd"]] <- .frequentistItemSd(jaspResults, dataset, options, model)

  .frequentistScaleTable(         jaspResults, model, options)
  .frequentistItemTable(          jaspResults, model, options)
  .frequentistSingleFactorFitTable(jaspResults, model, options)

  return()

}

.frequentistDerivedOptions <- function(options) {

  derivedOptions <- list(
    selectedEstimators  = unlist(options[c("omegaScale","alphaScale", "lambda2Scale", "lambda6Scale",
                                            "glbScale", "averageInterItemCor", "meanScale", "sdScale")]),
    itemDroppedSelected = unlist(options[c("omegaItem", "alphaItem", "lambda2Item", "lambda6Item",
                                            "glbItem", "itemRestCor", "itemMean", "itemSd")]),
    namesEstimators     = list(
      tables = c("McDonald's \u03C9", "Cronbach's \u03B1", "Guttman's \u03BB2", "Guttman's \u03BB6",
                 "Greatest Lower Bound", "Average interitem correlation", "mean", "sd"),
      tables_item = c("McDonald's \u03C9", "Cronbach's \u03B1", "Guttman's \u03BB2", "Guttman's \u03BB6",
                      gettext("Greatest Lower Bound"), gettext("Item-rest correlation"), gettext("mean"), gettext("sd")),
      coefficients = c("McDonald's \u03C9", "Cronbach's \u03B1", "Guttman's \u03BB2", "Guttman's \u03BB6",
                       gettext("Greatest Lower Bound"))
    )
  )
  return(derivedOptions)
}
