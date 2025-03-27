import numpy as np
from sklearn.linear_model import LinearRegression
from numba import njit

@njit
def generate_correlated_BMs(N, M, rho):
    Z1 = np.random.randn(N, M)
    Z2 = np.random.randn(N, M)
    W1 = Z1
    W2 = rho * Z1 + np.sqrt(1 - rho ** 2) * Z2
    return W1, W2

@njit
def simulate_heston_paths(S0, v0, kappa, theta, sigma, r, rho, T, M, N):
    dt = T / M
    S = np.zeros((N, M + 1))
    v = np.zeros((N, M + 1))
    S[:, 0] = S0
    v[:, 0] = v0
    W1, W2 = generate_correlated_BMs(N, M, rho)

    for t in range(1, M + 1):
        v[:, t] = np.maximum(v[:, t-1] + kappa * (theta - v[:, t-1]) * dt + sigma * np.sqrt(v[:, t-1] * dt) * W2[:, t-1], 0)
        S[:, t] = S[:, t-1] * np.exp((r - 0.5 * v[:, t-1]) * dt + np.sqrt(v[:, t-1] * dt) * W1[:, t-1])
    return S, v

@njit
def simulate_bs_paths(S0, sigma, r, T, M, N):
    dt = T / M
    S = np.zeros((N, M + 1))
    S[:, 0] = S0
    for t in range(1, M + 1):
        Z = np.random.randn(N)
        S[:, t] = S[:, t-1] * np.exp((r - 0.5 * sigma**2) * dt + sigma * np.sqrt(dt) * Z)
    return S

def least_squares_monte_carlo(S, K, r, T, M):
    dt = T / M
    intrinsic_values = np.maximum(K - S, 0)
    cashflows = intrinsic_values[:, -1].copy()
    total_paths = S.shape[0]
    exercised_early = np.zeros(total_paths, dtype=bool)

    for t in range(M - 1, 0, -1):
        in_the_money = intrinsic_values[:, t] > 0
        X = S[in_the_money, t].reshape(-1, 1)
        Y = cashflows[in_the_money] * np.exp(-r * dt)
        if len(Y) > 0:
            model = LinearRegression().fit(X, Y)
            continuation_value = model.predict(X)
            exercise = intrinsic_values[in_the_money, t] > continuation_value
            exercised_early[in_the_money] |= exercise
            cashflows[in_the_money] = np.where(
                exercise,
                intrinsic_values[in_the_money, t],
                cashflows[in_the_money] * np.exp(-r * dt)
            )

    early_exercise_freq = np.mean(exercised_early)
    price = np.mean(cashflows) * np.exp(-r * dt)
    return price, early_exercise_freq

def heston_simulations(S0, K, T, r, kappa, theta, sigma, rho, v0, M, N, num_simulations):
    option_prices = np.zeros(num_simulations)
    early_ex_freqs = np.zeros(num_simulations)
    for i in range(num_simulations):
        S, _ = simulate_heston_paths(S0, v0, kappa, theta, sigma, r, rho, T, M, N)
        price, freq = least_squares_monte_carlo(S, K, r, T, M)
        option_prices[i] = price
        early_ex_freqs[i] = freq
    return option_prices, early_ex_freqs

def bs_simulations(S0, K, T, r, sigma, M, N, num_simulations):
    option_prices = np.zeros(num_simulations)
    early_ex_freqs = np.zeros(num_simulations)
    for i in range(num_simulations):
        S = simulate_bs_paths(S0, sigma, r, T, M, N)
        price, freq = least_squares_monte_carlo(S, K, r, T, M)
        option_prices[i] = price
        early_ex_freqs[i] = freq
    return option_prices, early_ex_freqs
