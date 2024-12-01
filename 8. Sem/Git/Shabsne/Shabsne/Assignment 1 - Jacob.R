library("tidyverse")
library("tidyquant")
library("scales")

# Defining the variable 'symbols', which contains the ticker names of the stocks in Dow Jones
symbols <- tq_index("DOW") |> 
  filter(company != "US DOLLAR") # Removing the US DOLLAR

# Downloading prices from Yahoo Finance, using the previsouly created variable 'symbols'
index_prices <- tq_get(symbols, get = "stock.prices", from = "2000-01-01", to = "2023-12-31")

# Filtering out symbols, that are not present for the entire period
index_prices_filtered <- index_prices %>%
  mutate(year = year(date)) %>%
  group_by(symbol) %>%
  mutate(start_year = min(year), end_year = max(year)) %>% # Calculate both start_year and end_year
  ungroup() %>%
  filter(start_year == 2000, end_year == 2023) %>% # Filter for symbols starting in 2000 and ending in 2023
  select(-start_year, -end_year, -year) # Remove the year columns

# Calculating monthly_returns
monthly_returns <- index_prices_filtered %>%
  group_by(symbol) %>%
  tq_transmute(select = adjusted, 
               mutate_fun = periodReturn, 
               period = 'monthly', 
               col_rename = 'monthly_return', 
               type = 'log') %>%
  ungroup()