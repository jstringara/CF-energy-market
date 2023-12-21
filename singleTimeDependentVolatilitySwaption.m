function [C, sigma_hat] = singleTimeDependentVolatilitySwaption(sigma_int_increments, F0, K, T, DF)
    % Price a swaption with time-dependent volatility using the Black 76 formula
    % the model is of the form:
    %   dF/F = sigma_1(t) dW_1 + sigma_2 dW_2
    % where W_1 and W_2 are independent Brownian motions
    %   sigma_1(t, T1, T2) is a piecewise constant function of time
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

    arguments
        sigma_int_increments (:,1) double {mustBePositive, mustBeNonempty}
        F0 double
        K (:,1) double
        T (:,1) double
        DF (:,1) double
    end

    % validate the inputs
    % sigma_1, T and DF must be vectors of the same size
    validateattributes(sigma_int_increments, {'double'}, {'size', size(T)});
    validateattributes(DF, {'double'}, {'size', size(T)});

    % compute the integral of the squared volatility for each maturity
    sigma_1_int = cumsum(sigma_int_increments);

    sigma_hat = sqrt(sigma_1_int);

    % compute the price of the swaption for each maturity and strike
    C = Black76SwaptionBatch(F0, K, T, DF, sigma_hat);

    % sigma hat is the same for all strikes
    sigma_hat = repmat(sigma_hat, 1, length(K));

end