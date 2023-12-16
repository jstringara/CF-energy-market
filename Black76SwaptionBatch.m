function C = Black76SwaptionBatch(F0, T, K, DF, sigma_hat)
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

    C = zeros(length(T), length(K));

    for i = 1:length(T)
        for j = 1:length(K)
            % price is the max of the Black76 price and 0 (negative prices are not possible)
            % DF(i) is the discount factor at time T(i)
            C(i, j) = max(Black76Swaption(F0, T(i), K(j), DF(i), sigma_hat(i)), 0);
        end
    end

end