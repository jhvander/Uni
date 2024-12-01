rm(list=ls())
library("tidyverse")
library("RSQLite")
library("ggplot2")
library("dplyr")
library("lubridate")
library("broom")
library("scales")
library("purrr")
library("knitr")
library("lmtest")
library("sandwich")
library("nloptr")

tidy_finance <- dbConnect(SQLite(), 
                          "/Users/jvander/Library/Mobile Documents/com~apple~CloudDocs/Documents/#University/8. Sem/AEF/Data/tidy_finance_r.sqlite",  #Change this according to your local server
                          extended_types = TRUE)

# Loading in CRSP data and choosing the specified variables needed for this analysis.     
crsp_monthly <- tbl(tidy_finance, "crsp_monthly") 
crsp_monthly <- crsp_monthly |> 
  collect() |>
  select(permno, month, ret_excess)


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

# Print the result
print(paste("Amount of stocks in data:", num_unique_permnos))

data_wide <- crsp_monthly_filtered |>
  pivot_wider(names_from = permno, values_from = ret_excess) |>
  select(-month)
mu <- colMeans(data_wide, na.rm = TRUE)  #Mean Returns 
Sigma <- cov(data_wide, use = "complete.obs")  #Variance-Covariance-matrix

#Equally weigthed portfolio
assets <- ncol(data_wide)
weights <- rep(1/assets, assets) #Could just have been a number since we've denoted earlier


#Stefans portfolio
compute_efficient_weight <- function(Sigma,
                                     mu,
                                     gamma = 4,
                                     lambda = 0, # transaction costs
                                     w_prev = rep(
                                       1 / ncol(Sigma),
                                       ncol(Sigma)
                                     )) {
  iota <- rep(1, ncol(Sigma))
  Sigma_processed <- Sigma * (1 + (2 * lambda) / gamma)
  mu_processed <- mu + 2 * lambda * Sigma * w_prev
  
  Sigma_inverse <- solve(Sigma_processed)
  
  w_mvp <- Sigma_inverse %*% iota
  w_mvp <- as.vector(w_mvp / sum(w_mvp))
  w_opt <- w_mvp + 1 / gamma *
    (Sigma_inverse - w_mvp %*% t(iota) %*% Sigma_inverse) %*%
    mu_processed
  
  return(as.vector(w_opt))
}

w_efficient <- compute_efficient_weight(Sigma, mu)
round(w_efficient, 3)

w_mvp <- solve(Sigma) %*% rep(1, assets)
w_mvp <- as.vector(w_mvp / sum(w_mvp))

w_initial <- rep(1 / assets, assets)

objective_mvp <- function(w) {
  0.5 * t(w) %*% Sigma %*% w
}

gradient_mvp <- function(w) {
  Sigma %*% w
}

equality_constraint <- function(w) {
  sum(w) - 1
}

jacobian_equality <- function(w) {
  rep(1, assets)
}

options <- list(
  "xtol_rel"=1e-20, 
  "algorithm" = "NLOPT_LD_SLSQP", 
  "maxeval" = 10000
)

w_mvp_numerical <- nloptr(
  x0 = w_initial, 
  eval_f = objective_mvp, 
  eval_grad_f = gradient_mvp,
  eval_g_eq = equality_constraint,
  eval_jac_g_eq = jacobian_equality,
  opts = options
)

all(near(w_mvp, w_mvp_numerical$solution))

objective_efficient <- function(w) {
  2 * 0.5 * t(w) %*% Sigma %*% w - sum((1 + mu) * w)
}

gradient_efficient <- function(w) {
  2 * Sigma %*% w - (1 + mu)
}

w_efficient_numerical <- nloptr(
  x0 = w_initial, 
  eval_f = objective_efficient, 
  eval_grad_f = gradient_efficient,
  eval_g_eq = equality_constraint, 
  eval_jac_g_eq = jacobian_equality,
  opts = options
)

all(near(w_efficient, w_efficient_numerical$solution))

w_no_short_sale <- nloptr(
  x0 = w_initial, 
  eval_f = objective_efficient, 
  eval_grad_f = gradient_efficient,
  eval_g_eq = equality_constraint, 
  eval_jac_g_eq = jacobian_equality,
  lb = rep(0, assets),
  opts = options
)

round(w_no_short_sale$solution, 3)

#Backtesting
window_length <- 120
periods <- nrow(data_wide) - window_length

lambda <- 50
gamma <- 2

performance_values <- matrix(NA,
                             nrow = periods,
                             ncol = 3
)
colnames(performance_values) <- c("raw_return", "turnover", "net_return")

performance_values <- list(
  "Naive" = performance_values,
  "Stefan" = performance_values,
  "No-Short" = performance_values
)

w_prev_1 <- w_prev_2 <- w_prev_3 <- rep(
  1 / assets, assets)

adjust_weights <- function(w, next_return) {
  w_prev <- 1 + w * next_return
  as.numeric(w_prev / sum(as.vector(w_prev)))
}

evaluate_performance <- function(w, w_previous, next_return, beta = 50) {
  raw_return <- as.matrix(next_return) %*% w
  turnover <- sum(abs(w - w_previous))
  net_return <- raw_return - beta / 10000 * turnover
  c(raw_return, turnover, net_return)
}

for (p in 1:periods) {
  returns_window <- industry_returns[p:(p + window_length - 1), ]
  next_return <- industry_returns[p + window_length, ] |> as.matrix()

  Sigma <- cov(returns_window)
  mu <- 0 * colMeans(returns_window)

  # Transaction-cost adjusted portfolio
  w_1 <- compute_efficient_weight_L1_TC(
    mu = mu,
    Sigma = Sigma,
    beta = beta,
    gamma = gamma,
    initial_weights = w_prev_1
  )

  performance_values[[1]][p, ] <- evaluate_performance(w_1,
    w_prev_1,
    next_return,
    beta = beta
  )

  w_prev_1 <- adjust_weights(w_1, next_return)

  # Naive portfolio
  w_2 <- rep(1 / n_industries, n_industries)

  performance_values[[2]][p, ] <- evaluate_performance(
    w_2,
    w_prev_2,
    next_return
  )

  w_prev_2 <- adjust_weights(w_2, next_return)

  # Mean-variance efficient portfolio (w/o transaction costs)
  w_3 <- compute_efficient_weight(
    Sigma = Sigma,
    mu = mu,
    gamma = gamma
  )

  performance_values[[3]][p, ] <- evaluate_performance(
    w_3,
    w_prev_3,
    next_return
  )

  w_prev_3 <- adjust_weights(w_3, next_return)
}


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