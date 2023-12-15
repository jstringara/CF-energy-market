function C = price_swaption_MC(F0, K, T, r, sigma_1, sigma_2, N_sim, W1, W2)

    % F0: is the initial price of the underlying swap
    % K: is the strike price
    % T: is the vector of maturities

    % Simulate the underlying swap
    F = swap_MC(F0, T, r, sigma_1, sigma_2, N_sim, W1, W2);


    % Calculate the payoff of the swaption at each maturity T
    % and for each strike K
    C = zeros(length(T), length(K));
    for i = 1:length(T)
        for j = 1:length(K)
            C(i,j) = mean(max(F(:,i) - K(j), 0));
        end
    end

end