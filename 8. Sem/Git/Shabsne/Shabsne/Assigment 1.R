
# needed packages
library(tidyverse)
library(tidyquant)
library(scales)

## Exercise 1
# download prices for a full index
symbols <- tq_index("DOW") |>
  filter(company != "US DOLLAR")
symbols


# index prices
index_prices <- tq_get(symbols,
                       get = "stock.prices",
                       from = "2000-01-01",
                       to = "2023-12-31"
                       )

# Adding a lag variable to compute returns
all_returns <- index_prices |>
  group_by(symbol) |>
  mutate(ret = adjusted / lag(adjusted) - 1) |>
  select(symbol, date, ret) |>
  drop_na(ret)

# print returns
all_returns |>
  group_by(symbol) |>
  summarize(across(
    ret,
    list(
      daily_mean = mean,
      daily_sd = sd,
      daily_min = min,
      daily_max = max
    ),
    .names = "{.fn}"
  )) |>
  print(n = Inf)

rm()
# removing tickers with no continous trading history
index_prices <- index_prices |>
  group_by(symbol) |>
  mutate(n = n()) |>
  ungroup() |>
  filter(n == max(n)) |>
  select(-n)

# monthly return
returns <- index_prices |>
  mutate(month = floor_date(date, "month")) |>
  group_by(symbol, month) |>
  summarize(price = last(adjusted), .groups ="drop_last") |>
  mutate(ret = price / lag(price) -1) |>
  drop_na(ret) |>
  select(-price)

# Showing the tickers with continous trading history
returns |>
  group_by(symbol) |>
  summarize(across(
    ret,
    list(
      monthly_mean = mean,
      monthly_sd = sd,
      monthly_min = min,
      monthly_max = max
    ),
    .names = "{.fn}"
  )) |>
  print(n = Inf)



## Exercise 2
# The vector of sample mean and the variance-covariance matrix
returns_matrix <- returns |>
  pivot_wider(
    names_from = symbol,
    values_from = ret
  ) |>
  select(-month)
sigma <- cov(returns_matrix)
mu <- colMeans(returns_matrix)



## Exercise 3
# The MVP weights
N <- ncol(returns_matrix)
iota <- rep(1, N)
sigma_inv <- solve(sigma)
mvp_weights <- sigma_inv %*% iota
mvp_weights <- mvp_weights / sum(mvp_weights)

# The expected portfolio return and volatility
tibble(
  average_ret = as.numeric(t(mvp_weights) %*% mu),
  volatility = as.numeric(sqrt(t(mvp_weights) %*% sigma %*% mvp_weights))
)



