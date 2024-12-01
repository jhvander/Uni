# Importerer de vigtige pakker
library("tidyverse")
library("tidyquant")
library("scales")

# Henter priser
prices <- tq_get("AAPL",
                 get = "stock.prices",
                 from = "2000-01-01",
                 to = "2022-12-31")

# Tjek hvad tq_get har hentet af data
str(prices)

# Lav et plot af priserne med adjusted priser
prices |>
  ggplot(aes(x = date, y = adjusted)) +
  geom_line() +
  labs(
    x = "Dato",
    y = "Pris",
    title = "APPL priser")

# Beregner afkast
returns <- prices |>
  arrange(date) |>
  mutate(ret = adjusted / lag(adjusted) - 1) |>
  select(symbol, date, ret)
returns

# Fjerner NA return fra den første obs
returns <- returns |>
  drop_na(ret)

# Tjekker maks og min observationer hurtigt i konsol
min(returns$ret, na.rm = TRUE)
max(returns$ret, na.rm = TRUE)

# Laver et histogram over afkast
quantile_05 <- quantile(returns |> pull(ret), probs = 0.05)
returns |>
  ggplot(aes(x = ret)) +
  geom_histogram(bins = 100) +
  geom_vline(aes(xintercept = quantile_05),
             linetype = "dashed"
  ) +
  labs(
    x = NULL,
    y = NULL,
    title = "Distribution of daily Apple stock returns"
  ) +
  scale_x_continuous(labels = percent)



