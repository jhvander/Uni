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
        v[:, t] = np.maximum(
            v[:, t-1]
            + kappa * (theta - v[:, t-1]) * dt
            + sigma * np.sqrt(v[:, t-1] * dt) * W2[:, t-1],
            0
        )
        S[:, t] = S[:, t-1] * np.exp(
            (r - 0.5 * v[:, t-1]) * dt
            + np.sqrt(v[:, t-1] * dt) * W1[:, t-1]
        )
    return S, v

@njit
def simulate_bs_paths(S0, sigma, r, T, M, N):
    dt = T / M
    S = np.zeros((N, M + 1))
    S[:, 0] = S0
    for t in range(1, M + 1):
        Z = np.random.randn(N)
        S[:, t] = S[:, t-1] * np.exp(
            (r - 0.5 * sigma**2) * dt
            + sigma * np.sqrt(dt) * Z
        )
    return S

def laguerre_basis(x):
    return np.column_stack([
        np.ones_like(x),               # L0
        1 - x,                         # L1
        1 - 2*x + 0.5*x**2             # L2
    ])

def least_squares_monte_carlo(S, v, K, r, T, M,
                              track_boundary=False,
                              track_timing=False):
    """
    S, v: arrays shape (N, M+1)
    Regression onto [L0, L1, L2, v, v^2]
    """
    dt = T / M
    N = S.shape[0]
    intrinsic = np.maximum(K - S, 0)
    cashflows = intrinsic[:, -1].copy()
    exercised_early = np.zeros(N, dtype=bool)
    boundary = np.full(M+1, np.nan) if track_boundary else None
    times    = np.full(N,  np.nan) if track_timing  else None

    for t in range(M-1, 0, -1):
        itm = intrinsic[:, t] > 0
        if not np.any(itm):
            continue

        # Build regression matrix X = [L0, L1, L2, v, v^2]
        x_norm = (S[itm, t] / K).reshape(-1,1)
        L      = laguerre_basis(x_norm.flatten())
        vcol   = v[itm, t].reshape(-1,1)
        X      = np.hstack([L, vcol, vcol**2])

        Y = cashflows[itm] * np.exp(-r * dt)
        model = LinearRegression().fit(X, Y)
        cont  = model.predict(X)

        exercise = intrinsic[itm, t] > cont
        idxs     = np.where(itm)[0]

        if track_timing:
            for idx, ex in zip(idxs, exercise):
                if ex and np.isnan(times[idx]):
                    times[idx] = t * dt

        exercised_early[itm] |= exercise
        cashflows[itm] = np.where(
            exercise,
            intrinsic[itm, t],
            cashflows[itm] * np.exp(-r * dt)
        )

        if track_boundary and np.any(exercise):
            boundary[t] = S[itm, t][exercise].max()

    price = np.exp(-r*dt) * cashflows.mean()
    freq  = exercised_early.mean()

    if track_boundary and track_timing:
        return price, freq, boundary, times
    if track_boundary:
        return price, freq, boundary
    if track_timing:
        return price, freq, times
    return price, freq

def heston_simulations(S0, K, T, r,
                       kappa, theta, sigma, rho, v0,
                       M, N, num_simulations):
    option_prices = np.zeros(num_simulations)
    early_freqs   = np.zeros(num_simulations)
    for i in range(num_simulations):
        S_paths, v_paths = simulate_heston_paths(
            S0, v0, kappa, theta, sigma, r, rho, T, M, N
        )
        price, freq = least_squares_monte_carlo(
            S_paths, v_paths, K, r, T, M
        )
        option_prices[i] = price
        early_freqs[i]   = freq
    return option_prices, early_freqs

def bs_simulations(S0, K, T, r, sigma, M, N, num_simulations):
    """
    For Black–Scholes we fabricate a constant‐variance array.
    """
    option_prices = np.zeros(num_simulations)
    early_freqs   = np.zeros(num_simulations)
    for i in range(num_simulations):
        S_paths = simulate_bs_paths(S0, sigma, r, T, M, N)
        # build a dummy v‐array (constant variance = sigma^2)
        v_paths = np.full_like(S_paths, sigma**2)
        price, freq = least_squares_monte_carlo(
            S_paths, v_paths, K, r, T, M
        )
        option_prices[i] = price
        early_freqs[i]   = freq
    return option_prices, early_freqs

# --- Binomial Tree Implementation (unchanged) ---
def binomial_american_put(S0, K, T, r, sigma, M):
    dt = T / M
    u = np.exp(sigma * np.sqrt(dt))
    d = 1 / u
    p = (np.exp(r * dt) - d) / (u - d)

    ST = np.array([S0 * u**j * d**(M-j) for j in range(M+1)])
    option_values = np.maximum(K - ST, 0)
    early_exercise_boundary = np.full(M+1, np.nan)

    for t in range(M-1, -1, -1):
        new_vals = np.zeros(t+1)
        for j in range(t+1):
            S_tj = S0 * u**j * d**(t-j)
            exercise = max(K - S_tj, 0)
            hold = np.exp(-r*dt)*(p*option_values[j+1] + (1-p)*option_values[j])
            new_vals[j] = max(exercise, hold)
            if exercise > hold and np.isnan(early_exercise_boundary[t]):
                early_exercise_boundary[t] = S_tj
        option_values = new_vals

    return option_values[0], early_exercise_boundary

def binomial_simulations(S0, K, T, r, sigma, M, num_simulations):
    option_prices = np.zeros(num_simulations)
    boundary_matrix = np.full((num_simulations, M+1), np.nan)
    for i in range(num_simulations):
        price, boundary = binomial_american_put(S0, K, T, r, sigma, M)
        option_prices[i]   = price
        boundary_matrix[i] = boundary
    return option_prices, boundary_matrix
