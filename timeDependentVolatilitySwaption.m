function C = timeDependentVolatilitySwaption(sigma_1, alpha, sigma_2, F0, K, T, DF, T1)
    % Price a swaption with time-dependent volatility using the Black 76 formula
    % the model is of the form:
    %   dF/F = sigma_1(t) dW_1 + sigma_2 dW_2
    % where W_1 and W_2 are independent Brownian motions
    %   TODO: write the formula
    %   sigma_1(T_1, t) = sigma_1 * exp(-alpha *(T_1 - t))
    %   sigma_2 = constant
    % 
    % Inputs:
    %   sigma_1 and alpha: parameters of the time-dependent volatility
    %   T_1: the beginning of the swap 
    %   T_2: the end of the swap
    %   sigma_2: the constant volatility
    %   F0: the price of the swap at the time of pricing
    %   K: vector of strike prices
    %   T: vector of maturities
    %
    % Outputs:
    %   C: matrix of prices of swaptions with rows corresponding to strikes
    %   and columns corresponding to maturities
    %

    % compute the integral of the squared volatility for each maturity
    sigma_1_int = sigma_1^2 / (2 * alpha) * exp(-2 * alpha * T1) * (exp(2 * alpha * T) - 1);
    sigma_2_int = sigma_2^2 * T;
    sigma_hat = sqrt(sigma_1_int + sigma_2_int);

    % compute the price of the swaption for each maturity and strike
    C = Black76SwaptionBatch(F0, T, K, sigma_hat, DF);
end