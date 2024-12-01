

# Loading necessary libraries
library("dplyr")
library("RSQLite")
library("ggplot2")
library("purrr")
library("knitr")
library("lmtest")
library("sandwich")
library("nloptr")


# Loading in CRSP data
crsp_monthly <- tbl(tidy_finance, "crsp_monthly") %>%
  collect() %>%
  select(permno, month, ret_excess)

# Filtering data within the specified range
start_date <- as.Date("1962-01-01")
end_date <- as.Date("2020-12-31")
all_months <- seq(from = start_date, to = end_date, by = "month")

crsp_monthly_filtered <- crsp_monthly %>%
  filter(month >= start_date & month <= end_date) %>%
  group_by(permno) %>%
  filter(all(all_months %in% month)) %>%
  ungroup()

# Preparing the data in wide format for analysis
data_wide <- crsp_monthly_filtered %>%
  pivot_wider(names_from = permno, values_from = ret_excess) %>%
  select(-month)

compute_efficient_weight <- function(Sigma, mu, gamma, lambda, w_prev) {
  iota <- rep(1, ncol(Sigma))
  Sigma_processed <- Sigma + lambda * diag(iota)
  mu_processed <- mu - lambda * w_prev
  
  Sigma_inverse <- solve(Sigma_processed)
  w_mvp <- Sigma_inverse %*% iota
  w_mvp <- w_mvp / sum(w_mvp)
  w_opt <- w_mvp + 1 / gamma * (Sigma_inverse - w_mvp %*% t(iota) %*% Sigma_inverse) %*% mu_processed
  
  return(w_opt)
}

# Define initial weights and parameters
assets <- ncol(data_wide)
w_initial <- rep(1 / assets, assets)
gamma <- 2
lambda <- 200 / 10000 # 200 basis points

#Simulate portfolio strategies over a window
window_length <- 120 # number of months in the rolling window
periods <- nrow(data_wide) - window_length

performance_values <- matrix(NA, nrow = periods, ncol = 3)
colnames(performance_values) <- c("raw_return", "turnover", "net_return")

#Define strategies

strategies <- list(
  "Naive" = performance_values,
  "Optimal_TC" = performance_values,
  "MeanVariance" = performance_values
)

#Initialize previous weights for all strategies

w_prev <- list(
  "Naive" = rep(1 / assets, assets),
  "Optimal_TC" = rep(1 / assets, assets),
  "MeanVariance" = rep(1 / assets, assets)
)

#Iterate over each period for backtesting

for (p in 1:periods) {
  returns_window <- data_wide[p:(p + window_length - 1), ]
  next_return <- data_wide[p + window_length, ]
  
  Sigma <- cov(returns_window, use = "complete.obs")
  mu <- colMeans(returns_window, na.rm = TRUE)
  
  #Naive strategy: equally weighted portfolio
  
  strategies$Naive[p, ] <- evaluate_performance(rep(1 / assets, assets), w_prev$Naive, next_return, lambda = 0)
  w_prev$Naive <- rep(1 / assets, assets) # No change in weights, always equally distributed
  
  #Optimal TC strategy: transaction-cost adjusted weights
  
  strategies$Optimal_TC[p, ] <- evaluate_performance(
    compute_efficient_weight(Sigma, mu, gamma, lambda, w_prev$Optimal_TC),
    w_prev$Optimal_TC,
    next_return,
    lambda
  )
  w_prev$Optimal_TC <- compute_efficient_weight(Sigma, mu, gamma, lambda, w_prev$Optimal_TC)
  
  #Mean-Variance strategy: classic mean-variance optimization without transaction costs
  
  strategies$MeanVariance[p, ] <- evaluate_performance(
    compute_efficient_weight(Sigma, mu, gamma, 0, w_prev$MeanVariance), # No transaction costs
    w_prev$MeanVariance,
    next_return,
    0
  )
  w_prev$MeanVariance <- compute_efficient_weight(Sigma, mu, gamma, 0, w_prev$MeanVariance)
}

#Function to evaluate the performance of a portfolio strategy
evaluate_performance <- function(w_new, w_prev, next_return, beta) {
  raw_return <- sum(w_new * next_return)
  turnover <- sum(abs(w_new - w_prev))
  net_return <- raw_return - beta / 10000 * turnover # Adjusting for transaction costs
  return(c(raw_return, turnover, net_return))
}

#Aggregating and analyzing results

results <- bind_rows(lapply(strategies, as_tibble), .id = "strategy")
analyze_performance(results)

analyze_performance <- function(results) {
  results %>%
    group_by(strategy) %>%
    summarize(
      mean_return = mean(raw_return, na.rm = TRUE),
      sd_return = sd(raw_return, na.rm = TRUE),
      sharpe_ratio = mean_return / sd_return,
      mean_turnover = mean(turnover, na.rm = TRUE)
    ) %>%
    arrange(desc(sharpe_ratio))
}