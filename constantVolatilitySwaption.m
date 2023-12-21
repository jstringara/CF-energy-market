function [C, sigma_hat] = constantVolatilitySwaption(sigma_1, sigma_2, F0, K, T, DF)
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

    arguments
        sigma_1 (1,1) double {mustBePositive}
        sigma_2 (1,1) double {mustBePositive}
        F0 (1,1) double {mustBePositive}
        K (:,1) double {mustBePositive}
        T (:,1) double {mustBePositive}
        DF (:,1) double {mustBePositive}
    end

    % validate the inputs
    % DF and T must be the same size
    validateattributes(DF, {'double'}, {'size', size(T)});

    % compute the integral of the squared volatility for each maturity
    sigma_1_int = sigma_1^2 .* T;
    sigma_2_int = sigma_2^2 .* T;
    sigma_hat = sqrt(sigma_1_int + sigma_2_int);

    % compute the prices of the swaption for each maturity and strike
    C = Black76SwaptionBatch(F0, K, T, DF, sigma_hat);

    % sigma_hat must be transformed into a matrix with the same size as C
    % it is the same for each strike
    sigma_hat = repmat(sigma_hat, 1, size(C, 2));

end