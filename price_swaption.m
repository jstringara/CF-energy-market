function C = price_swaption(F0, K, T,r, sigma_1, sigma_2)
    % F0: is the initial price of the underlying swap
    % K: is the strike price
    % T: is the time to maturity

    sigma_hat = sqrt(sigma_1^2 * T + sigma_2^2 * T);
    d2= (log(F0)/K - 0.5 * sigma_hat) / (sigma_hat);
    d1 = d2 + sigma_hat;

    C = exp(-r * T) * (F0 * normcdf(d1) - K * normcdf(d2));