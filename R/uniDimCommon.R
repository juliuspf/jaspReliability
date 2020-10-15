

.readData <- function(dataset, options) {

  variables <- unlist(options[["variables"]])
  if (is.null(dataset)) {
    dataset <- .readDataSetToEnd(columns.as.numeric = variables, columns.as.factor = NULL, exclude.na.listwise = NULL)
  }
  return(dataset)
}

.checkErrors <- function(dataset, options) {

  # check for existing inverse
  .checkInverse <- function() {
    if (length(options[["variables"]]) > 2) {
      use.cases <- "everything"
      if (anyNA(dataset)) {
        if (options[["missingValues"]] == "excludeCasesPairwise")
          use.cases <- "pairwise.complete.obs"
        else if (options[["missingValues"]] == "excludeCasesListwise")
          use.cases <- "complete.obs"
      }
      if (isTryError(try(solve(cov(dataset, use = use.cases)),silent=TRUE))) {
        return(gettext("The covariance matrix of the data is not invertible"))
      }
    }
    return(NULL)
  }

  .hasErrors(dataset = dataset, options = options, perform = "run",
             type = c("infinity", "variance", "observations", "varCovData"),
             observations.amount = " < 3",
             varCovData.corFun = function(x) cor(x, use = "pairwise.complete.obs"),
             custom = .checkInverse,
             exitAnalysisIfErrors = TRUE)

}


.checkLoadings <- function(dataset, variables) {
  if (ncol(dataset > 2)) {
    prin <- psych::principal(dataset)
    idx <- prin[["loadings"]] < 0
    sidx <- sum(idx)
    if (sidx == 0) {
      footnote <- ""
    } else {
      footnote <- sprintf(ngettext(length(variables[idx]),
                                   "The following item correlated negatively with the scale: %s. ",
                                   "The following items correlated negatively with the scale: %s. "),
                          paste(variables[idx], collapse = ", "))
    }
  } else {
    return("Please enter at least 3 Variables to do an analysis")
  }
}

.reverseScoreItems <- function(dataset, options) {
  dataset_rev <- as.matrix(dataset) # fails for string factors!
  cols <- match(unlist(options[["reverseScaledItems"]]), .unv(colnames(dataset)))
  total <- apply(as.matrix(dataset[, cols]), 2, min, na.rm = T) + apply(as.matrix(dataset[, cols]), 2, max, na.rm = T)
  dataset_rev[ ,cols] <- matrix(rep(total, nrow(dataset)), nrow(dataset), length(cols), byrow=T) - dataset[ ,cols]
  return(dataset_rev)
}


.cov2cor.callback <- function(C, callback) {
  callback()
  return(cov2cor(C))
}

# calculate the kublack leibler distance between two samples
.KLD.statistic <- function(x, y) {
  # transform the samples to PDFs:
  xdf <- .get_approx_density(x)
  ydf <- .get_approx_density(y)

  xx <- seq(0, 1, length.out = 1e4)
  t <- LaplacesDemon::KLD(xdf(xx), ydf(xx))
  t$sum.KLD.py.px
}

# calculate the kolomogorov smirnov distances between some samples and the original sample
.ks.test.statistic <- function(x, y) {
  t <- stats::ks.test(x, y)
  t$statistic
}

# konvert empirical samples to cumulative density functions
.get_approx_density <- function(x) {
  d <- density(x, n = 2^12)
  f <- approxfun(d$x, d$y, yleft = 0, yright = 0)
  c <- integrate(f, 0, 1)$value
  return(
    function(x) {
      return(f(x) / c)
    }
  )
}

.itemRestCor <- function(dataset, n.iter, n.burnin, thin, n.chains, missing, callback) {

  ircor_samp <- array(0, c(n.chains, length(seq(1, n.iter-n.burnin, thin)), ncol(dataset)))
  for (i in 1:ncol(dataset)) {
    help_dat <- cbind(dataset[, i], rowMeans(dataset[, -i], na.rm = T))
    ircor_samp[, , i] <- .WishartCorTransform(help_dat, n.iter = n.iter, n.burnin = n.burnin, thin = thin,
                                              n.chains = n.chains, missing = missing, callback = callback)
  }

  return(ircor_samp)
}

.WishartCorTransform <- function(x, n.iter, n.burnin, thin, n.chains, missing, callback) {
  tmp_cov <- Bayesrel:::covSamp(x, n.iter, n.burnin, thin, n.chains, pairwise = missing, callback)$cov_mat
  tmp_cor <- apply(tmp_cov, c(1, 2), cov2cor)
  out <- tmp_cor[2, , ]
  callback()
  return(out)
}