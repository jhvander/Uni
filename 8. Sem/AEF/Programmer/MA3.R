# Loading libraries
rm(list = ls())
library("tidyverse")
library("RSQLite")
library("ggplot2")
library("dplyr")
library("lubridate")
library("broom")
library("scales")
library("purrr")
library("nloptr")
library("quadprog")
library("knitr")
library("lmtest")
library("sandwich")

# Setting up Tidy Finance
tidy_finance <- dbConnect(SQLite(), 
                          "/Users/jvander/Library/Mobile Documents/com~apple~CloudDocs/Documents/#University/8. Sem/AEF/Data/tidy_finance_r.sqlite", 
                          extended_types = TRUE)

# Loading in CRSP data    
crsp_monthly <- tbl(tidy_finance, "crsp_monthly") %>%
  select(permno, month, ret_excess) %>%
  collect()

# Define the filtering range
start_date <- as.Date("1962-01-01")
end_date <- as.Date("2020-12-31")

# Generate the complete sequence of months from 1962 to 2020
all_months <- seq(from = start_date, to = end_date, by = "month")

# Filter by the date range and for permno with complete data
crsp_monthly_filtered <- crsp_monthly %>%
  # Keep only records within the desired date range
  filter(month >= start_date & month <= end_date) %>%
  group_by(permno) %>%
  # Check if all months from 1962 to 2020 are present
  filter(all(all_months %in% month)) %>%
  ungroup()

# Count the number of unique permnos using base R functions
num_unique_permnos <- length(unique(crsp_monthly_filtered$permno))

# Transform data for Sigma estimation
data_wide <- crsp_monthly_filtered |>
  pivot_wider(names_from = permno, values_from = ret_excess) |>
  select(-month)

# Calculating mu
mu <- colMeans(data_wide, na.rm = TRUE)  #Mean Returns 



compute_ledoit_wolf <- function(x) {
  # Computes Ledoit-Wolf shrinkage covariance estimator
  # This function generates the Ledoit-Wolf covariance estimator  as proposed in Ledoit, Wolf 2004 (Honey, I shrunk the sample covariance matrix.)
  # X is a (t x n) matrix of returns
  t <- nrow(x)
  n <- ncol(x)
  x <- apply(x, 2, function(x) if (is.numeric(x)) # demean x
    x - mean(x) else x)
  sample <- (1/t) * (t(x) %*% x)
  var <- diag(sample)
  sqrtvar <- sqrt(var)
  rBar <- (sum(sum(sample/(sqrtvar %*% t(sqrtvar)))) - n)/(n * (n - 1))
  prior <- rBar * sqrtvar %*% t(sqrtvar)
  diag(prior) <- var
  y <- x^2
  phiMat <- t(y) %*% y/t - 2 * (t(x) %*% x) * sample/t + sample^2
  phi <- sum(phiMat)
  
  repmat = function(X, m, n) {
    X <- as.matrix(X)
    mx = dim(X)[1]
    nx = dim(X)[2]
    matrix(t(matrix(X, mx, nx * n)), mx * m, nx * n, byrow = T)
  }
  
  term1 <- (t(x^3) %*% x)/t
  help <- t(x) %*% x/t
  helpDiag <- diag(help)
  term2 <- repmat(helpDiag, 1, n) * sample
  term3 <- help * repmat(var, 1, n)
  term4 <- repmat(var, 1, n) * sample
  thetaMat <- term1 - term2 - term3 + term4
  diag(thetaMat) <- 0
  rho <- sum(diag(phiMat)) + rBar * sum(sum(((1/sqrtvar) %*% t(sqrtvar)) * thetaMat))
  
  gamma <- sum(diag(t(sample - prior) %*% (sample - prior)))
  kappa <- (phi - rho)/gamma
  shrinkage <- max(0, min(1, kappa/t))
  if (is.nan(shrinkage))
    shrinkage <- 1
  sigma <- shrinkage * prior + (1 - shrinkage) * sample
  return(sigma)
}

Sigma <- compute_ledoit_wolf(data_wide)

# Function to calculate efficient weights
compute_efficient_weight <- function(Sigma,
                                     mu,
                                     gamma,
                                     lambda, # transaction costs
                                     w_prev = rep(
                                       1 / ncol(Sigma),
                                       ncol(Sigma)
                                     )) {
  iota <- rep(1, ncol(Sigma))
  Sigma_processed <- Sigma * (1 + 2*lambda/gamma)
  mu_processed <- mu + lambda* 2 * (Sigma %*% w_prev)
  
  Sigma_inverse <- solve(Sigma_processed)
  
  w_mvp <- Sigma_inverse %*% iota
  w_mvp <- as.vector(w_mvp / sum(w_mvp))
  w_opt <- w_mvp + 1 / gamma *
    (Sigma_inverse - w_mvp %*% t(iota) %*% Sigma_inverse) %*%
    mu_processed
  
  return(as.vector(w_opt))
}

window_length <- 120
periods <- nrow(data_wide) - window_length

lambda <- 0.02
gamma <- 4

performance_values <- matrix(NA,
                             nrow = periods,
                             ncol = 3
)
colnames(performance_values) <- c("raw_return", "turnover", "net_return")

performance_values <- list(
  "Transaction-cost adjusted portfolio" = performance_values,
  "Naive" = performance_values,
  "MV" = performance_values
)

w_prev_1 <- w_prev_2 <- w_prev_3 <- rep(
  1 / num_unique_permnos,
  num_unique_permnos
)

adjust_weights <- function(w, next_return) {
  w_prev <- 1 + w * next_return
  as.numeric(w_prev / sum(as.vector(w_prev)))
}

evaluate_performance <- function(w, w_previous, next_return, lambda = 0.02) {
  raw_return <- as.matrix(next_return) %*% w
  turnover <- sum(abs(w - w_previous))
  net_return <- raw_return - lambda / 10000 * turnover
  c(raw_return, turnover, net_return)
}

for (p in 1:periods) {
  returns_window <- data_wide[p:(p + window_length - 1), ]
  next_return <- data_wide[p + window_length, ] |> as.matrix()
  
  mu <- 0 * colMeans(returns_window)
  
  # Transaction-cost adjusted portfolio
  w_1 <- compute_efficient_weight(
    mu = mu,
    Sigma = Sigma,
    lambda = lambda,
    gamma = gamma,
    w_prev = rep(
      1 / ncol(Sigma),
      ncol(Sigma)
    )
  )
  
  performance_values[[1]][p, ] <- evaluate_performance(w_1,
                                                       w_prev_1,
                                                       next_return,
                                                       lambda = lambda
  )
  
  w_prev_1 <- adjust_weights(w_1, next_return)
  
  # Naive portfolio
  w_2 <- rep(1 / num_unique_permnos, num_unique_permnos)
  
  performance_values[[2]][p, ] <- evaluate_performance(
    w_2,
    w_prev_2,
    next_return
  )
  
  w_prev_2 <- adjust_weights(w_2, next_return)
  
  # No short-selling
  w_3 <- solve.QP(Dmat = 2 * Sigma,
                  dvec = mu, 
                  Amat = cbind(1, diag(num_unique_permnos)), 
                  bvec = c(1, rep(0, num_unique_permnos)), 
                  meq = 1
  )$solution
  
  performance_values[[3]][p, ] <- evaluate_performance(w_3, 
                                                       w_prev_3, 
                                                       next_return)
  
  w_prev_3 <- adjust_weights(w_3, next_return)
  
  performance <- lapply(
    performance_values,
    as_tibble
  ) |>
    bind_rows(.id = "strategy")
  
  length_year <- 12
  
  performance_table <- performance |>
    group_by(Strategy = strategy) |>
    summarize(
      Mean = length_year * mean(100 * net_return),
      SD = sqrt(length_year) * sd(100 * net_return),
      `Sharpe ratio` = if_else(Mean > 0,
                               Mean / SD,
                               NA_real_
      ),
      Turnover = 100 * mean(turnover)
    )
  
  performance_table |> 
    mutate(across(-Strategy, ~round(., 4)))