library("tidyverse")
library("tidyquant")
library("RSQLite")
library("kableExtra")

prices_sp500 <- tq_get("^GSPC", from = "2000-01-01") |> select(date, adjusted)
prices_sp500 <- prices_sp500 |> 
  mutate(net_return = (adjusted-lag(adjusted))/lag(adjusted), #Pct-return
         gross_return = adjusted/lag(adjusted), 
         log_return = log(adjusted) / - log(lag(adjusted))) #Beregner  log-return 
head(prices_sp500)
prices_sp500 <- prices_sp500 |>
  drop_na() #Fjerner manglende observationerr

returns <-prices_sp500 |> 
  pull(net_return)

c(sum(returns)/length(returns), mean(returns)) #Daily average
c(sum((returns-mean(returns))^2)/(length(returns)-1), var(returns)) #Daily variance

#Estimate the sample variance-covariance matrix: E
prices <- tq_get(c("META", "AAPL", "MSFT"), from = "2000-01-01") #Henter data
price_matrix <- prices |>
  group_by(symbol) |> #Grupperer  per virksomhed 
  transmute(date, return = (adjusted - lag(adjusted))/lag(adjusted)) |> 
  pivot_wider(names_from = symbol, values_from = return) |> #Opstiller på matrix format
  drop_na() |> #Dropper NA observationer
  select(-date) #Fjerner dato-variablen fra vores datasæt

#Finder varians-covarians matricen for disse tre virksomheder
(sigma <- price_matrix |> 
    cov())

#Volatiltity is the standard deviation of the variance.  
bind_rows(100 * sqrt(250 * diag(sigma)), #Annualized  volatility in percent 
          100 * 250 *colMeans(price_matrix)) #Annualized  return in percent 
              
#Computing the minimum variance portfolio with R. Ligesom vi gjorde i EXCEL/FDM 
Sigma <- matrix(c(3,2,2,4), ncol = 2) #Arbitrær-matrice
Sigma_inv <- solve(Sigma) #Invers daddy 
z <- Sigma_inv %*% rep(1,2) #Invers daddt ganges med  1-vektor
w <- z/sum(z) 
w #Kalder på vægtene

#LOOOPSS i R  er givet på denne måde
for (value in c("Hello", "World,","This", "is", "my", "First", "R", "LOOOOP")){
  print(value)
}

#Skriver en funktion: 
compute_sum <- function(x,y) {
  return(x + y^2)
}
compute_sum(2,9) #Tester min funktion. 

#En funktion for finde en efficient portfolio. Brug Hygge med R til at skrive en portfolio vægt funktion
compute_efficient_portfolio <- function(sigma, mu, mu_bar=0.30/250){
  iota <- rep(1, ncol(sigma)) #Vector of ones 
  sigma_inv <- solve(sigma) #Den inverse 
  w_mvp <- sigma_inv %*% iota #Finder z
  w_mvp <- w_mvp / sum(w_mvp) #Finder vægtene  ved dividere z med Z. 
  C <- as.numeric(t(iota)%*%sigma_inv%*%iota) #Taking the weigthed  sum of all ones based on the risk-relationship between assets
  D <- as.numeric(t(iota)%*%sigma_inv%*%mu) #Represents the expected return of the portfolio with the lowest risk (the Minimum Variance Portfolio), using the inverse of the risk relationships
  E <- as.numeric(t(mu)%*%sigma_inv%*%mu) #Its a measure of the "efficiency" of returns when considering the risk
  lambda_tilde <- as.numeric(2*(mu_bar - D / C )/(E-D^2/C)) #Figuring out how much  extra risk we are willing to take on to achieve targeted return
  weff <- w_mvp + lambda_tilde/2*(sigma_inv%*%mu - D/C*sigma_inv%*%iota) #This line calculates the weights of the efficient portfolio
  return(t(weff)) #Hvad  funktioningen returnerer 
}
compute_efficient_portfolio(sigma = sigma, mu=colMeans(price_matrix)) 
compute_efficient_portfolio(sigma = sigma, mu=colMeans(price_matrix), mu_bar=0.25/250) #Sets the target daily expected return for the efficient portfolio to be 0.25 (or 25%) annualized, assuming there are 250 trading days in a year

N <- ncol(sigma) #Counts  the number of columns  in the matrix ie. number of assets
A <- t(rbind(1,  #Takes the  identity matrix and adds a row of ones.  
             diag(N))) #Creates  a diagonal NxN vector in the matrix
cbind(t(A), c(1, rep(0,N))) #Transpone  A -matrix. Creates a vector that starts with 1 and rest zeros. 

#Læs op på dette
solution <- quadprog::solve.QP(Dmat = 2 * sigma, 
                               dvec = colMeans(price_matrix),
                               Amat = A,
                               bvec = c(1, rep(0, N)), 
                               meq = 1) 
names(solution)

solution$solution #Plukker  "solution" fra datasættet solution 

#Henter data  fra en SQL fil. Extended = True betyder, at vi kan henter mere detaljeret data. 
tidy_finance <- dbConnect(SQLite(), "/Users/jvander/Library/Mobile Documents/com~apple~CloudDocs/Documents/#University/8. Sem/AEF/Data/tidy_finance_r.sqlite", extended_types = TRUE)
crsp_monthly <- tbl(tidy_finance, "crsp_monthly") |> #tbl creates a remote dataset.
  collect() # Collect takes the specified data

crsp_monthly |> #Tager det forhenværende  dataasæt 
  count(exchange, date) |> #Counts the number of exchanges   and dates
  ggplot(aes(x = date, y = n, color = exchange)) + geom_line() + #X-aksen er dato, Y-aksen er antallet af aktier/virksomheder
  labs(x = NULL, y = NULL, color = NULL, title = "Monthly number of securities by listing exchange")

crsp_monthly |> 
  left_join(tbl(tidy_finance, "cpi_monthly") |> 
              collect(), join_by(month)) |> #Merging two dataset  taking the cpi column from another dataset and matching via month
  group_by(month, industry) |> #Grupperer efter måned og industri
  summarize(mktcap = sum(mktcap / cpi) / 1000000) |> 
  ggplot(aes(x = month, y = mktcap, color = industry)) + geom_line() + #Plotting for each individual industri 
  labs(x = NULL, y = NULL, color = NULL, title = "Market Cap by industri (in trillion USD)") 

raw_crsp_monthly |> #Kan  ikke få denne til at virke?
  mutate(ret_adj = case_when(
    is.na(dlstcd) ~ ret,
    !is.na(dlstcd) & !is.na(dlret) ~ dlret, 
    dlstcd %in% c(500, 520, 580, 584) | (dlstcd >= 551 & dlstcd <= 574) ~ 0.30,
    dlstcd == 100 ~ ret, 
    TRUE ~ - 1)) |>
  select(-c(dlret,dlstcd))

#Excess  return for a stock is the difference between the stock return and the return on the risk-free security over the same period 
#Monthly risk-free security return data from Ken French's data library
factors_ff_monthly <- tbl(tidy_finance, "factors_ff3_monthly") |> 
  collect() #Henter Fama-French  Factor 3
factors_ff_monthly |> #Plotter denne data
  ggplot(aes(x = month, y = 100 * rf)) + 
  geom_line() + 
  labs(x = NULL, y = NULL, title = "Risk free rate(Percentage)")

#we mainly  work with adjusted excess retuns
crsp_monthly |> 
  group_by(month) |>
  summarise(across(ret_excess, 
                   list(mean = mean, sd = sd, min = min, #Calculates quite clearly what it states
                        q25 = ~ quantile(., 0.25), 
                        median = median, 
                        q75 = ~ quantile(., 0.75), 
                        max = max), 
                   .names = "{.fn} return" )) |>
  summarize(across(-month, mean)) |>
  kableExtra::kable() #Can be altered to put out LaTeX files 

#The  market risk premia is the market excess return z_t= r_m - r_f
#We  proxy this market as the value-weighted portfolio of US-Based common stocks in CRSP. 
factors_ff_monthly |> 
  mutate(mkt_excess = 100 * mkt_excess) |>
  summarise(across(mkt_excess, list(mean = ~ 12 * mean(.), 
                                    sd = ~ sqrt(12)*sd(.),
                                    Sharpe = ~sqrt(12) * mean(.)/ sd(.) ),
                   .names = "{.fn} (annualized)")) |>
  kableExtra::kable() #Kan udskrive til HTML/LaTeX

#Simple  linear regression(OLS) 
apple_monthly <- crsp_monthly |> 
  filter(permno == 19764) |> #19764  =  APPLE 
  left_join(factors_ff_monthly) #Merging  the FF Factor into the dataset
capm_regression <- lm(ret_excess ~ mkt_excess, data = apple_monthly) #lm() is a linear regression . y = x, data = "Dataset"
capm_regression |>
  broom::tidy() |> #Turns  the statistical analysis objects into a tidy dataframe. Creates a line per variable
  knitr::kable() #Makes it compatible and easily readable. 

apple_monthly |>
  ggplot(aes(x = mkt_excess, y = ret_excess)) + geom_point() + #Creates a scatterplot. 
  geom_smooth(method = "lm", se = FALSE) + #Adds  a regressionline. Use method = "lm ~linear model " 
  labs(x = "Market Excess Return",  y = "AAPL Market Returns") #Names the  x-and y-axis. 
  
#Estimating Beta
roll_capm_estimation <- function(data, months, min_obs) { #Inputs are the dataset, the months and the minimum_obs
  data <- data |> #Takes  the external dataset and arranges after month. 
    arrange(month)
  
  betas <- slide_period_vec( 
    .x = data, 
    .i = data$month,#In the dataset "data" we plug the month variable. 
    .period = "month", #Defines what type of period should be used. Here we define the variable month as the period. 
    .f = ~ estimate_capm(., min_obs),
    .before = months - 1, #Concludes  how  many periods before  the period, we should include. Months - 1. 
    .complete = FALSE #Specifies if not fully fitted variables should be used or not. 
    )
  return(tibble(month = unique(data$month),  #Tibble is a type of dataframe. 
                beta = betas))
}  

beta <- tbl(tidy_finance, "beta") |> #Collects data from the dataset tidy_finance and collects the "beta" values. 
  collect() |>
  inner_join(crsp_monthly, join_by(month, permno)) |> #This merges the "beta" hauled from the tidy_finance. Merging on Ticker and month                             
  drop_na(beta_monthly) #Drops all N/A observations. We drop the whole row.
beta |> 
  group_by(industry, permno) |> #Grouping the datasets by the Ticker and the industry
  summarise(beta = mean(beta_monthly)) |> #Finding the mean  of the monthly beta grouped by month , industri and Ticker
  ggplot(aes(x = reorder(industry, beta, FUN = median), y = beta)) + #Reorder  = reorders the x-axis after the median value. 
  geom_boxplot() + coord_flip()+  #Laver et. fucking boxplot 
  labs(x = NULL, y = NULL, title = "Firm-specific beta distributions by industri")

beta_portfolios <- beta |> 
  group_by(month) |> #Grouping data  after months
  mutate(breakpoint = median(beta_monthly), #Calculates the median. 
         portfolio = case_when(beta_monthly <= breakpoint ~ "low", #Case_when is  an if operator(Seeking a specific case). If the beta-value is lower or equal to the median, then categorized as low. 
                               beta_monthly > breakpoint ~ "high")) |> #If the value is higher than the median, then categorized as higher
  group_by(month, portfolio) |> #Extends the grouping  by portfolio. 
  summarise(ret = weighted.mean(ret_excess, mktcap_lag), .groups = "drop") #Weighing the  weights based on the market cap of each firm/ticker we calculate the returns, based on the excess returns. Furthermore, we drop the grouping

beta_portfolios |>
  pivot_wider(names_from = portfolio, values_from = ret) |> #Creates  a N x N vector. Column names are tickers, values taken from the returns
  mutate(long_short = high - low) |>  #Creates a new  variable
  left_join(factors_ff_monthly) |> #Merges back the factor 
  lm(long_short ~ mkt_excess, data = _) |>   #Linear model with y as long_short and x as mkt_excess( market return - risk free)  
  broom::tidy() #Turns  the statistical analysis objects into a tidy dataframe. Creates a line per variable. 