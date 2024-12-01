library("RSQLite")
library("tidyverse")
library("tidymodels")
library("scales")
library("furrr")
library("glmnet")
library("timetk")

tidy_finance <- dbConnect(
  SQLite(),
  "/Users/jvander/Library/Mobile Documents/com~apple~CloudDocs/Documents/#University/8. Sem/AEF/Data/tidy_finance_r.sqlite",
  extended_types = TRUE
)

factors_ff3_monthly <- tbl(tidy_finance, "factors_ff3_monthly") |>
  collect() |>
  rename_with(~ str_c("factor_ff_", .), -month)

factors_q_monthly <- tbl(tidy_finance, "factors_q_monthly") |>
  collect() |>
  rename_with(~ str_c("factor_q_", .), -month)

macro_predictors <- tbl(tidy_finance, "macro_predictors") |>
  collect() |>
  rename_with(~ str_c("macro_", .), -month) |>
  select(-macro_rp_div)

industries_ff_monthly <- tbl(tidy_finance, "industries_ff_monthly") |>
  collect() |>
  pivot_longer(-month,
               names_to = "industry", values_to = "ret"
  ) |>
  arrange(desc(industry)) |> 
  mutate(industry = as_factor(industry))

data <- industries_ff_monthly |>
  left_join(factors_ff3_monthly, join_by(month)) |>
  left_join(factors_q_monthly, join_by(month)) |>
  left_join(macro_predictors, join_by(month)) |>
  mutate(
    ret = ret - factor_ff_rf
  ) |>
  select(month, industry, ret_excess = ret, everything()) |>
  drop_na()

data |>
  group_by(industry) |>
  ggplot(aes(x = industry, y = ret_excess)) +
  geom_boxplot() +
  coord_flip() +
  labs(
    x = NULL, y = NULL,
    title = "Excess return distributions by industry in percent"
  ) +
  scale_y_continuous(
    labels = percent
  )

split <- initial_time_split(
  data |>
    filter(industry == "manuf") |>
    select(-industry),
  prop = 4 / 5
)
split

rec <- recipe(ret_excess ~ ., data = training(split)) |>
  step_rm(month) |>
  step_interact(terms = ~ contains("factor"):contains("macro")) |>
  step_normalize(all_predictors())

data_prep <- prep(rec, training(split))

data_bake <- bake(data_prep,
                  new_data = testing(split)
)
data_bake

lm_model <- linear_reg(
  penalty = 0.0001,
  mixture = 1
) |>
  set_engine("glmnet", intercept = FALSE)

lm_fit <- workflow() |>
  add_recipe(rec) |>
  add_model(lm_model)
lm_fit

predicted_values <- lm_fit |>
  fit(data = training(split)) |>
  predict(data |> filter(industry == "manuf")) |>
  bind_cols(data |> filter(industry == "manuf")) |>
  select(month,
         "Fitted value" = .pred,
         "Realization" = ret_excess
  ) |>
  pivot_longer(-month, names_to = "Variable")

  predicted_values |>
    ggplot(aes(
      x = month, 
      y = value, 
      color = Variable,
      linetype = Variable
    )) +
    geom_line() +
    labs(
      x = NULL,
      y = NULL,
      color = NULL,
      linetype = NULL,
      title = "Monthly realized and fitted manufacturing industry risk premia"
    ) +
    scale_x_date(
      breaks = function(x) {
        seq.Date(
          from = min(x),
          to = max(x),
          by = "5 years"
        )
      },
      minor_breaks = function(x) {
        seq.Date(
          from = min(x),
          to = max(x),
          by = "1 years"
        )
      },
      expand = c(0, 0),
      labels = date_format("%Y")
    ) +
    scale_y_continuous(
      labels = percent
    ) +
    annotate("rect",
             xmin = testing(split) |> pull(month) |> min(),
             xmax = testing(split) |> pull(month) |> max(),
             ymin = -Inf, ymax = Inf,
             alpha = 0.5, fill = "grey70"
    )
  
  x <- data_bake |>
    select(-ret_excess) |>
    as.matrix()
  y <- data_bake |> pull(ret_excess)
  
  fit_lasso <- glmnet(
    x = x,
    y = y,
    alpha = 1,
    intercept = FALSE,
    standardize = FALSE,
    lambda.min.ratio = 0
  )
  
  fit_ridge <- glmnet(
    x = x,
    y = y,
    alpha = 0,
    intercept = FALSE,
    standardize = FALSE,
    lambda.min.ratio = 0
  )
  
  bind_rows(
    tidy(fit_lasso) |> mutate(Model = "Lasso"),
    tidy(fit_ridge) |> mutate(Model = "Ridge")
  ) |>
    rename("Variable" = term) |>
    ggplot(aes(x = lambda, y = estimate, color = Variable)) +
    geom_line() +
    scale_x_log10() +
    facet_wrap(~Model, scales = "free_x") +
    labs(
      x = "Penalty factor (lambda)", y = NULL,
      title = "Estimated coefficient paths for different penalty factors"
    ) +
    theme(legend.position = "none")
  
  
  lm_model <- linear_reg(
    penalty = tune(),
    mixture = tune()
  ) |>
    set_engine("glmnet")
  
  lm_fit <- lm_fit |>
    update_model(lm_model)
  
  
  data_folds <- time_series_cv(
    data        = training(split),
    date_var    = month,
    initial     = "5 years",
    assess      = "48 months",
    cumulative  = FALSE,
    slice_limit = 20
  )
  data_folds
  
  lm_tune <- lm_fit |>
    tune_grid(
      resample = data_folds,
      grid = grid_regular(penalty(), mixture(), levels = c(20, 3)),
      metrics = metric_set(rmse)
    )
  
  autoplot(lm_tune) + 
    aes(linetype = `Proportion of Lasso Penalty`) + 
    guides(linetype = "none") +
    labs(
      x = "Penalty factor (lambda)",
      y = "Root MSPE",
      title = "Root MSPE for different penalty factors"
    ) + 
    scale_x_log10()
  