function C = constantVolatilitySwaption(sigma_1, sigma_2, F0, K, T, DF)
    % Price a swaption with constant volatility using the Black 76 formula
    % the model is of the form:
    %   dF/F = sigma_1 dW_1 + sigma_2 dW_2
    % where W_1 and W_2 are independent Brownian motions
    % sigma_1 and sigma_2 are constants
    % 
    % Inputs:
    %   sigma_1 and sigma_2: the volatilities of the two Brownian motions
    %   F0: the price of the swap at the time of pricing
    %   K: vector of strike prices
    %   T: vector of maturities
    %
    % Outputs:
    %   C: matric of prices of swaptions with rows corresponding to strikes
    %   and columns corresponding to maturities
    %

    % compute the integral of the squared volatility for each maturity
    sigma_1_int = sigma_1^2 * T;
    sigma_2_int = sigma_2^2 * T;
    sigma_hat = sqrt(sigma_1_int + sigma_2_int);

    % compute the price of the swaption for each maturity and strike
    C = Black76SwaptionBatch(F0, T, K, sigma_hat, DF);
    
end