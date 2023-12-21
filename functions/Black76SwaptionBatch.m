function C = Black76SwaptionBatch(F0, K, T, DF, sigma_hat)

% Black76SwaptionBatch: Black76 swaption price on a batch of swaptions
%
% Parameters:
%   F0: forward swap rate at the time of pricing
%   T: vector of swaption maturities
%   K: vector of swaption strikes
%   DF: vector of discount factors, where DF(i) is the discount factor at
%       time T(i)
%   sigma_hat: vector containing the square root of the sum of the integrated
%       volatilities squared from t=0 to T_i, where T_i is the ith
%       maturity in T
%   
%
% Output:
%   C: matrix of swaption prices, where each row is a maturity and each
%       column is a strike
%
    arguments
        F0 double
        K (:, 1) double
        T (:, 1) double
        DF(:, 1) double
        sigma_hat(:,1) double
    end

    % validate inputs
    % DF, T, and sigma_hat must be the same size
    validateattributes(DF, {'double'}, {'size', size(T)});
    validateattributes(sigma_hat, {'double'}, {'size', size(T)});

    C = zeros(length(T), length(K));

    % iterate over the given maturities and strikes
    for i = 1:length(T)
        for j = 1:length(K)
            C(i, j) = Black76(F0, K(j), T(i), DF(i), sigma_hat(i));
        end
    end

end