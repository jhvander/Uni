library("tidyverse")
library("RSQLite")
library("scales")
library("lmtest")
library("broom")
library("sandwich")

tidy_finance <- dbConnect(
  SQLite(),
  "/Users/jvander/Library/Mobile Documents/com~apple~CloudDocs/Documents/#University/8. Sem/AEF/Data/tidy_finance_r.sqlite",
  extended_types = TRUE
)

crsp_monthly <- tbl(tidy_finance, "crsp_monthly") |>
  select(permno, month, ret_excess, mktcap_lag) |>
  collect()

factors_ff3_monthly <- tbl(tidy_finance, "factors_ff3_monthly") |>
  select(month, mkt_excess) |>
  collect()

beta <- tbl(tidy_finance, "beta") |>
  select(permno, month, beta_monthly) |>
  collect()

beta_lag <- beta |>
  mutate(month = month %m+% months(1)) |>
  select(permno, month, beta_lag = beta_monthly) |>
  drop_na()

data_for_sorts <- crsp_monthly |>
  inner_join(beta_lag, join_by(permno, month))

beta_portfolios <- data_for_sorts |>
  group_by(month) |>
  mutate(
    breakpoint = median(beta_lag),
    portfolio = case_when(
      beta_lag <= breakpoint ~ "low",
      beta_lag > breakpoint ~ "high"
    )
  ) |>
  group_by(month, portfolio) |>
  summarize(ret = weighted.mean(ret_excess, mktcap_lag), 
            .groups = "drop")

beta_longshort <- beta_portfolios |>
  pivot_wider(id_cols = month, names_from = portfolio, values_from = ret) |>
  mutate(long_short = high - low)

model_fit <- lm(long_short ~ 1, data = beta_longshort)
coeftest(model_fit, vcov = NeweyWest)

assign_portfolio <- function(data, 
                             sorting_variable, 
                             n_portfolios) {
  # Compute breakpoints
  breakpoints <- data |>
    pull({{ sorting_variable }}) |>
    quantile(
      probs = seq(0, 1, length.out = n_portfolios + 1),
      na.rm = TRUE,
      names = FALSE
    )
  
  # Assign portfolios
  assigned_portfolios <- data |>
    mutate(portfolio = findInterval(
      pick(everything()) |>
        pull({{ sorting_variable }}),
      breakpoints,
      all.inside = TRUE
    )) |>
    pull(portfolio)
  
  # Output
  return(assigned_portfolios)
}

beta_portfolios <- data_for_sorts |>
  group_by(month) |>
  mutate(
    portfolio = assign_portfolio(
      data = pick(everything()),
      sorting_variable = beta_lag,
      n_portfolios = 10
    ),
    portfolio = as.factor(portfolio)
  ) |>
  group_by(portfolio, month) |>
  summarize(
    ret_excess = weighted.mean(ret_excess, mktcap_lag),
    .groups = "drop"
  )|>
  left_join(factors_ff3_monthly, join_by(month))


beta_portfolios_summary <- beta_portfolios |>
  nest(data = c(month, ret_excess, mkt_excess)) |>
  mutate(estimates = map(
    data, ~ tidy(lm(ret_excess ~ 1 + mkt_excess, data = .x))
  )) |>
  unnest(estimates) |> 
  select(portfolio, term, estimate) |> 
  pivot_wider(names_from = term, values_from = estimate) |> 
  rename(alpha = `(Intercept)`, beta = mkt_excess) |> 
  left_join(
    beta_portfolios |> 
      group_by(portfolio) |> 
      summarize(ret_excess = mean(ret_excess),
                .groups = "drop"), join_by(portfolio)
  )

beta_portfolios_summary |>
  ggplot(aes(x = portfolio, y = alpha, fill = portfolio)) +
  geom_bar(stat = "identity") +
  labs(
    title = "CAPM alphas of beta-sorted portfolios",
    x = "Portfolio",
    y = "CAPM alpha",
    fill = "Portfolio"
  ) +
  scale_y_continuous(labels = percent) +
  theme(legend.position = "None")

sml_capm <- lm(ret_excess ~ 1 + beta, data = beta_portfolios_summary)$coefficients

beta_portfolios_summary |>
  ggplot(aes(
    x = beta, 
    y = ret_excess, 
    color = portfolio
  )) +
  geom_point() +
  geom_abline(
    intercept = 0,
    slope = mean(factors_ff3_monthly$mkt_excess),
    linetype = "solid"
  ) +
  geom_abline(
    intercept = sml_capm[1],
    slope = sml_capm[2],
    linetype = "dashed"
  ) +
  scale_y_continuous(
    labels = percent,
    limit = c(0, mean(factors_ff3_monthly$mkt_excess) * 2)
  ) +
  scale_x_continuous(limits = c(0, 2)) +
  labs(
    x = "Beta", y = "Excess return", color = "Portfolio",
    title = "Average portfolio excess returns and average beta estimates"
  )

beta_longshort <- beta_portfolios |>
  mutate(portfolio = case_when(
    portfolio == max(as.numeric(portfolio)) ~ "high",
    portfolio == min(as.numeric(portfolio)) ~ "low"
  )) |>
  filter(portfolio %in% c("low", "high")) |>
  pivot_wider(id_cols = month, 
              names_from = portfolio, 
              values_from = ret_excess) |>
  mutate(long_short = high - low) |>
  left_join(factors_ff3_monthly, join_by(month))

coeftest(lm(long_short ~ 1, data = beta_longshort),
         vcov = NeweyWest
)

coeftest(lm(long_short ~ 1 + mkt_excess, data = beta_longshort),
         vcov = NeweyWest
)

beta_longshort |>
  group_by(year = year(month)) |>
  summarize(
    low = prod(1 + low),
    high = prod(1 + high),
    long_short = prod(1 + long_short)
  ) |>
  pivot_longer(cols = -year) |>
  ggplot(aes(x = year, y = 1 - value, fill = name)) +
  geom_col(position = "dodge") +
  facet_wrap(~name, ncol = 1) +
  theme(legend.position = "none") +
  scale_y_continuous(labels = percent) +
  labs(
    title = "Annual returns of beta portfolios",
    x = NULL, y = NULL
  )
