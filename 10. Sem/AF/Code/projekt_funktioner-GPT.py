import numpy as np
import scipy.stats as stats
from sklearn.linear_model import LinearRegression
from sklearn.neural_network import MLPRegressor

def bs_put(start_price, Rf, t_year, strike, sigma):
    d1 = (np.log(start_price / strike) + (Rf + 0.5 * sigma**2) * t_year) / (sigma * np.sqrt(t_year))
    d2 = d1 - sigma * np.sqrt(t_year)
    return strike * np.exp(-Rf * t_year) * stats.norm.cdf(-d2) - start_price * stats.norm.cdf(-d1)

def bs_put_minimum(start_price1, start_price2, Rf, t_year, strike, sigma1, sigma2):
    d1_1 = (np.log(start_price1 / strike) + (Rf + 0.5 * sigma1**2) * t_year) / (sigma1 * np.sqrt(t_year))
    d2_1 = d1_1 - sigma1 * np.sqrt(t_year)
    d1_2 = (np.log(start_price2 / strike) + (Rf + 0.5 * sigma2**2) * t_year) / (sigma2 * np.sqrt(t_year))
    d2_2 = d1_2 - sigma2 * np.sqrt(t_year)
    
    var = sigma1**2 + sigma2**2
    d2_1 = (np.log(start_price2 / start_price1) - var / 2 * t_year) / np.sqrt(var * t_year)
    d2_2 = (np.log(start_price1 / start_price2) - var / 2 * t_year) / np.sqrt(var * t_year)
    
    rho1, rho2 = sigma1 / np.sqrt(var), sigma2 / np.sqrt(var)
    cov1, cov2, cov3 = np.array([[1, -rho1], [-rho1, 1]]), np.array([[1, -rho2], [-rho2, 1]]), np.eye(2)
    
    call_min = (
        start_price1 * stats.multivariate_normal.cdf([d2_1, d1_1], cov=cov1) +
        start_price2 * stats.multivariate_normal.cdf([d2_2, d1_2], cov=cov2) -
        strike * np.exp(-Rf * t_year) * stats.multivariate_normal.cdf([d2_1, d2_2], cov=cov3)
    )
    call_min_0 = start_price1 * stats.norm.cdf(d2_1) + start_price2 * stats.norm.cdf(d2_2)
    return call_min - call_min_0 + strike * np.exp(-Rf * t_year)

def european_put_price(paths, Rf, strike, t_year):
    return np.mean(np.exp(-Rf * t_year) * np.maximum(strike - paths[:, -1], 0))

def european_put_minimum_price(paths1, paths2, Rf, strike, t_year):
    return np.mean(np.exp(-Rf * t_year) * np.maximum(strike - np.minimum(paths1[:, -1], paths2[:, -1]), 0))

def lsm_put(paths, Rf, strike, t_year, return_stopping=False):
    n, periods = paths.shape
    dt = t_year / (periods - 1)
    discount_factor = np.exp(-Rf * dt)
    cash_flow = np.maximum(strike - paths[:, -1], 0) * discount_factor
    stopping_rule = [] if return_stopping else None
    
    for i in range(periods - 2, 0, -1):
        temp_cash_flow = np.maximum(strike - paths[:, i], 0)
        in_the_money = temp_cash_flow > 0
        
        if np.any(in_the_money):
            X = np.column_stack((paths[:, i], paths[:, i]**2))
            model = LinearRegression().fit(X[in_the_money, :], cash_flow[in_the_money])
            
            if return_stopping:
                stopping_rule.append(model)
            
            continuation_value = model.predict(X)
            exercise = temp_cash_flow >= continuation_value
            cash_flow[exercise] = temp_cash_flow[exercise]
        
        cash_flow *= discount_factor
    
    if return_stopping:
        stopping_rule.append(None)
        stopping_rule.reverse()
        return np.mean(cash_flow), stopping_rule
    return np.mean(cash_flow)

def monte_carlo_simulation(start_price, Rf, sigma, n, t_year, dt=1/50):
    periods = int(1 / dt * t_year) + 1
    paths = np.empty([n, periods])
    paths[:, 0] = start_price if isinstance(start_price, int) else start_price
    
    increments = np.random.normal(0, np.sqrt(dt), [n, periods - 1])
    drift = (Rf - 0.5 * sigma**2) * dt
    paths[:, 1:] = np.exp(drift + sigma * increments).cumprod(axis=1) * paths[:, 0, None]
    
    return paths

def binomial_put(start_price, Rf, sigma, n, t_year, strike, option_type="european"):
    dt = t_year / n
    discount_factor = np.exp(-Rf * dt)
    u, d = np.exp(sigma * np.sqrt(dt)), 1 / np.exp(sigma * np.sqrt(dt))
    q = (np.exp(Rf * dt) - d) / (u - d)
    
    index = np.arange(-n, n + 1, 2)
    price = np.maximum(strike - start_price * u**index, 0)
    
    for j in range(n - 1, -1, -1):
        index = np.arange(-j, j + 1, 2)
        exercise_price = np.maximum(strike - start_price * u**index, 0)
        continuation_price = (q * price[1:j + 2] + (1 - q) * price[0:j + 1]) * discount_factor
        
        if option_type == "european":
            price[:j + 1] = continuation_price
        else:
            price[:j + 1] = np.maximum(exercise_price, continuation_price)
    
    return price[0]
