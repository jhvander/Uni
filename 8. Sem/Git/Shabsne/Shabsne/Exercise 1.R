library("tidyverse")
library("tidyquant")
library("scales")

#Collecting the price data for the APPLE Stock
#Hej hej 
prices <- tq_get("AAPL",
                 get = "stock.prices",
                 from = "2000-01-01",
                 to = "2022-12-31"
)
prices
#Plotting the APPLE stock data
prices |>
  ggplot(aes(x =date, y = adjusted)) + 
  geom_line() + 
  labs(
    x=NULL,
    y=NULL,
    tilte ="Apple stock prices between beginning of 2000 and 2022"
  )
#Calculates the pct.change 
returns <- prices |>
  arrange(date) |>
  mutate(ret = adjusted / lag(adjusted) -1)|> #Lag tager observationen før
  select(symbol, date, ret)
#Drops the first observation, as there was no previous observation. 
returns <- returns |>
  drop_na(ret)
#Calculates the quantiles of the returns. 
quantile_05 <-quantile(returns |> pull(ret), probs = 0.05)
quantile_95 <-quantile(returns |> pull(ret), probs = 0.95)
#Creates a histogram for the returns with dashed lines as enclosement
returns |> 
  ggplot(aes(x = ret)) + 
  geom_histogram(bins=100) + 
  geom_vline(aes(xintercept = quantile_05),
            linetype = "dashed" ) +
 geom_vline(aes(xintercept = quantile_95),
             linetype = "dashed" ) +
  labs(
    x=NULL, #Ingen x-legende
    y=NULL, #Ingen y-legende
    title = "Distribtuion of daily Apple stock returns"
  ) + 
  scale_x_continuous(labels = percent)

#Calculates the average return, standard deviation, minimum_value and maximum_value
returns |>
  summarise(across(
    ret, 
    list(
      daily_mean = mean, 
      daily_sd = sd, 
      daily_min = min, 
      daily_max = max
    )
  ))
#Does  the same thing as above, just by grouping for each year in the dataset i.e 2000 - 2022
returns |>
  group_by(year= year(date)) |>
  summarise(across(ret, 
    list(
      daily_mean = mean, 
      daily_sd = sd, 
      daily_min = min, 
      daily_max = max
    ), 
    .names="{.fn}"
  )) |>
print(n = Inf)
#Scaling up the analysis. Taking the full DOW Jones Index. 
symbols <- tq_index("DOW") |>
  filter(company!="US DOLLAR")
symbols 

index_prices <- tq_get(symbols,  #Henter direkte fra en kilde. Dum smart
                       get = "stock.prices",
                       from = "2000-01-01",
                       to = "2022-12-31"
)
 
index_prices |>
  ggplot(aes(
    x = date, 
    y = adjusted, 
    color = symbol
  )) + 
  geom_line() +
  labs(
    x=NULL,
    y=NULL,
    color = NULL, 
    title = "Stock prices of DOW index constituents" 
  ) + 
  theme(legend.position = "none")

all_returns <- index_prices |>
  group_by(symbol) |>
  mutate(ret = adjusted/ lag(adjusted)-1)|>
  select(symbol, date, ret) |>
  drop_na(ret)

all_returns |> 
  group_by(symbol) |>
  summarise(across(
    ret, 
    list(
      daily_mean = mean, 
      daily_sd = sd, 
      daily_min = min, 
      daily_max = max 
    ), 
    .names = "{.fn}"
    )) |>
  print(n=Inf)


##########Andet#####################
trading_volume <- index_prices |> 
  group_by(date) |> 
  summarise(trading_volume = sum(volume * adjusted))

trading_volume |> 
  ggplot(aes(x = date, y = trading_volume)) + 
  geom_line() + 
  labs(
    x = NULL, y=NULL, 
    title = "Trading volume for DOW index constituents"
  ) + scale_y_continuous(labels = unit_format(unit = "B", scale = 1e-9))

trading_volume |> 
  ggplot(aes(x = lag(trading_volume), y = trading_volume)) + 
  geom_point() + #Punkter frem for linje
  geom_abline(aes(intercept = 0, slope = 1), #Arbitrær linje 
              linetype= "dashed"
  )+
  labs(
    x = "Previous day aggregate trading volume", 
    y = "Aggregrate trading volume", 
    title = "Persistence in daily trading volume of DOW index constituents" 
  )+ 
  scale_x_continuous(labels = unit_format(unit="B", scale = 1e-9)) + #Scale er længden af x/y - aksen 
  scale_y_continuous(labels = unit_format(unit="B", scale = 1e-9)) #Units = "B" beskriver størrelsesordenen. 
  
#Portfolio choices
index_prices <- index_prices |>
  group_by(symbol) |> #Grupperer per aktie 
  mutate(n = n()) |> #Tæller antallet af entriess
  ungroup() |>
  filter(n== max(n)) |> #Sikrer sig at alle aktier har samme antal entries. 
  select(-n) #Fjerner variablen n. 

returns <- index_prices |> 
  mutate(month = floor_date(date, "month")) |> #Tager værdien for den første i hver måned
  group_by(symbol, month) |> # Grupperer per aktie og måned
  summarise(price = last(adjusted), .groups="drop_last" ) |> #.groups_last ophæver den seneste gruppering
  mutate(ret = price/ lag(price)-1) |> #Beregner returns
  drop_na(ret) |>
  select(-price)
  
returns_matrix <- returns |> 
  pivot_wider( #Bruges til at opstille matrix
    names_from =symbol, #Med akser fra aktier
    values_from =  ret #Indeholdende værdier fra returns. 
    ) |>
  select(-month)
sigma <- cov(returns_matrix) #Varians-covarians matricen 
mu <- colMeans(returns_matrix, na.rm = TRUE) #Returns  

N<- ncol(returns_matrix) #Tæller antallet af aktier i vores returns matrice 
iota <- rep(1,N)  #Laver en "Ones" vektor lig antallet af aktier
sigma_inv <- solve(sigma) #Finder den inverse matrice af varians-covarians matrice
mvp_weights <- sigma_inv %*% iota  #Ganger den inverse matrice med "Ones"-vektoren - Finder Z - "%*%" - Gange matrix
mvp_weights <- mvp_weights / sum(mvp_weights) #Omdanner fra Z til vægte(x_1, x_2, x_3,.., x_i)
#Når vi har fundet Minimum Variance Portfolio(MVP), kan vi optimere den. 
tibble(
  average_ret = as.numeric(t(mvp_weights) %*% mu), #Finder average returns - (t(mvp_weights)) er en transpornering. 
  volatility = as.numeric(sqrt(t(mvp_weights) %*% sigma %*% mvp_weights)) #Finder volatiliteten 
)

benchmark_multiple <- 3
mu_bar <- benchmark_multiple * t(mvp_weights) %*% mu
C <- as.numeric(t(iota) %*% sigma_inv %*% iota)
D <- as.numeric(t(iota) %*% sigma_inv %*% mu)
E <- as.numeric(t(mu) %*% sigma_inv %*% mu)
lambda_tilde <- as.numeric(2 * (mu_bar - D / C) / (E - D^2 / C))
efp_weights <- mvp_weights +
  lambda_tilde / 2 * (sigma_inv %*% mu - D * mvp_weights)
#The Efficient Frontier 
length_year <- 12 
a <- seq(from = -0.4, to = 1.9, by = 0.01)
res <- tibble(
  a = a, 
  mu = NA, 
  sd = NA
)
for (i in seq_along(a)) {
  w <- (1-a[i]) * mvp_weights + (a[i]) * efp_weights
  res$mu[i] <- length_year * t(w) %*% mu 
  res$sd[i] <- sqrt(length_year) * sqrt(t(w) %*% sigma %*% w)
}

res |> 
  ggplot(aes(x = sd, y = mu)) + 
  geom_point() + 
  geom_point(
    data = res |> filter(a %in% c(0,1)), 
    size = 4
  ) + 
  geom_point( 
    data = tibble(
      mu = length_year * mu, 
      sd = sqrt(length_year) * sqrt(diag(sigma))
    ), 
    aes(y = mu, x = sd), size = 1
  )+ 
  labs(
    x = "Annualized standard deviation", 
    y = "Annualized expected return", 
    title = "Efficient frontier for DOW index consituents"
  ) + 
  scale_x_continuous(labels = percent) + 
  scale_y_continuous(labels = percent)
