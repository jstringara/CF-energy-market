function [C, sigma_hat] = timeDependentVolatilitySwaption(sigma1_increments, sigma2_increments, F0, K, T, DF)
    % Price a swaption with time-dependent volatility using the Black 76 formula
    % the model is of the form:
    %   dF/F = sigma_1(t) dW_1 + sigma_2 dW_2
    % where W_1 and W_2 are independent Brownian motions
    %   sigma_1(t, T1, T2) =
    %       sigma_1 / (alpha * (T2-T2)) * [ exp(-alpha * (T1-t)) - exp(-alpha * (T2-t))]
    %   sigma_2(t, T1, T2) =
    %       sigma_2 / (beta * (T2-T2)) * [ exp(-beta * (T1-t)) - exp(-beta * (T2-t))]
    % 
    % Inputs:
    %   sigma_1 and alpha: parameters of the first time-dependent volatility
    %   sigma_2 and beta: parameters of the second time-independent volatility
    %   T_1: the beginning of the swap 
    %   T_2: the end of the swap
    %   F0: the price of the swap at the time of pricing
    %   K: vector of strike prices
    %   T: vector of maturities
    %
    % Outputs:
    %   C: matrix of prices of swaptions with rows corresponding to strikes
    %   and columns corresponding to maturities
    %

    arguments
        sigma1_increments (:,1) double {mustBePositive, mustBeNonempty}
        sigma2_increments (:,1) double {mustBePositive, mustBeNonempty}
        F0 double
        K (:,1) double
        T (:,1) double
        DF (:,1) double
    end

    validateattributes(sigma1_increments, {'double'}, {'size', size(T)});
    validateattributes(sigma2_increments, {'double'}, {'size', size(T)});
    validateattributes(DF, {'double'}, {'size', size(T)});

    % compute the integral of the squared volatility for each maturity
    sigma_1_int = cumsum(sigma1_increments);
    sigma_2_int = cumsum(sigma2_increments);
    sigma_hat = sqrt(sigma_1_int + sigma_2_int);

    % compute the price of the swaption for each maturity and strike
    C = Black76SwaptionBatch(F0, K, T, DF, sigma_hat);

    sigma_hat = repmat(sigma_hat, 1, length(K));
end