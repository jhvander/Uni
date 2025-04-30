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

def laguerre_basis(x):
    return np.column_stack([
        np.ones_like(x),               # L0
        1 - x,                         # L1
        1 - 2 * x + 0.5 * x**2         # L2
    ])


def least_squares_monte_carlo(S, K, r, T, M, track_boundary=False, track_timing=False):
    dt = T / M
    intrinsic_values = np.maximum(K - S, 0)
    cashflows = intrinsic_values[:, -1].copy()
    total_paths = S.shape[0]
    exercised_early = np.zeros(total_paths, dtype=bool)
    early_exercise_boundary = np.full(M + 1, np.nan) if track_boundary else None
    exercise_times = np.full(total_paths, np.nan) if track_timing else None  # NEW

    for t in range(M - 1, 0, -1):
        in_the_money = intrinsic_values[:, t] > 0
        X = S[in_the_money, t].reshape(-1, 1)
        Y = cashflows[in_the_money] * np.exp(-r * dt)
        if len(Y) > 0:
            X_basis = laguerre_basis(X.flatten() / K)
            model = LinearRegression().fit(X_basis, Y)
            continuation_value = model.predict(X_basis)
            exercise = intrinsic_values[in_the_money, t] > continuation_value

            # NEW: Track timing of first early exercise
            if track_timing:
                for idx, ex in zip(np.where(in_the_money)[0], exercise):
                    if ex and np.isnan(exercise_times[idx]):
                        exercise_times[idx] = t * dt

            exercised_early[in_the_money] |= exercise
            cashflows[in_the_money] = np.where(
                exercise,
                intrinsic_values[in_the_money, t],
                cashflows[in_the_money] * np.exp(-r * dt)
            )

            if track_boundary and np.any(exercise):
                exercised_prices = X[exercise].flatten()
                early_exercise_boundary[t] = exercised_prices.max()

    price = np.mean(cashflows) * np.exp(-r * dt)
    early_exercise_freq = np.mean(exercised_early)
    if track_boundary and track_timing:
        return price, early_exercise_freq, early_exercise_boundary, exercise_times
    elif track_boundary:
        return price, early_exercise_freq, early_exercise_boundary
    elif track_timing:
        return price, early_exercise_freq, exercise_times
    else:
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

# --- Binomial Tree Implementation ---
def binomial_american_put(S0, K, T, r, sigma, M):
    dt = T / M
    u = np.exp(sigma * np.sqrt(dt))
    d = 1 / u
    p = (np.exp(r * dt) - d) / (u - d)

    # Terminal payoff
    ST = np.array([S0 * (u ** j) * (d ** (M - j)) for j in range(M + 1)])
    option_values = np.maximum(K - ST, 0)
    early_exercise_boundary = np.full(M + 1, np.nan)

    # Backward induction
    for t in range(M - 1, -1, -1):
        new_option_values = np.zeros(t + 1)
        for j in range(t + 1):
            S_tj = S0 * (u ** j) * (d ** (t - j))
            exercise_value = max(K - S_tj, 0)
            hold_value = np.exp(-r * dt) * (p * option_values[j + 1] + (1 - p) * option_values[j])
            new_option_values[j] = max(exercise_value, hold_value)

            if exercise_value > hold_value and np.isnan(early_exercise_boundary[t]):
                early_exercise_boundary[t] = S_tj
        option_values = new_option_values

    return option_values[0], early_exercise_boundary

def binomial_simulations(S0, K, T, r, sigma, M, num_simulations):
    option_prices = np.zeros(num_simulations)
    boundary_matrix = np.full((num_simulations, M + 1), np.nan)
    for i in range(num_simulations):
        price, boundary = binomial_american_put(S0, K, T, r, sigma, M)
        option_prices[i] = price
        boundary_matrix[i, :] = boundary
    return option_prices, boundary_matrix