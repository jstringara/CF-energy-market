function C = volsToPrices(S0, K, T, DF, vols)
    % volsToPrices(S0, K, T, DF, vols) computes the prices of European
    % call options with the given parameters and volatilities using the
    % classical Black-Scholes formula.
    %
    % inputs:
    %   S0: initial prices of the underlying asset
    %   K: vector of strike prices
    %   T: vector of maturities
    %   DF: vector of discount factors
    %   vols: matrix of volatilities
    %
    % output:
    %   C: matrix of prices
    %

    % argument check
    arguments
        S0 (1,1) {mustBeNumeric, mustBePositive}
        K (:,1) {mustBeNumeric, mustBePositive}
        T (:,1) {mustBeNumeric, mustBePositive}
        DF (:,1) {mustBeNumeric, mustBePositive}
        vols (:,:) {mustBeNumeric, mustBePositive}
    end

    % validation, DF must be of the same length as T
    validateattributes(DF, {'numeric'}, {'numel', length(T)});
    % vols must be of the same size as K and T
    validateattributes(vols, {'numeric'}, {'size', [length(T), length(K)]});

    % compute the prices
    C = zeros(length(T), length(K));
    for i = 1:length(T)
        for j = 1:length(K)
            % compute the sigma_hat
            sigma_hat = vols(i,j) * sqrt(T(i));
            % use the Black76 formula
            C(i,j) = Black76(S0, K(j), T(i), DF(i), sigma_hat);
        end
    end