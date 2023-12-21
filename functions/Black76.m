function C = Black76Swaption(F0, K, T, DF, sigma_hat)

% Black76Swaption: Black 76 swaption price
%
% Parameters:
%   F0: forward rate at the time of pricing
%   K: strike rate
%   T: time to maturity
%   DF: discount factor
%   sigma_hat: square root of the sum of the integral of the square of the
%       volatility function from t to T
%
% Output:
%   C: swaption price
%
%   C = DF * (F0 * N(d1) - K * N(d2))
%

    % arguments validation
    arguments
        F0 double
        K double
        T double
        DF double
        sigma_hat double
    end

    d2 = (log(F0/K) - 0.5 * sigma_hat^2) / (sigma_hat);
    d1 = d2 + sigma_hat;
    C = DF * (F0 * normcdf(d1) - K * normcdf(d2));

end