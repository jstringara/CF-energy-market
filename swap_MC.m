function F = swap_MC(F0, T, r, sigma_1, sigma_2, N_sim, W1, W2)

    % Calculate the price of the underlying swap at each maturity T
    % F_t = F_{t-1} * exp(r_t * (T_t - T_{t-1}) + sigma_1 * W1_t + sigma_2 * W2_t)
    F = zeros(N_sim, length(T));
    F(:, 1) = F0;
    for i = 2:length(T)
        F(:, i) = F(:, i-1) .* exp( -0.5 * (sigma_1^2+sigma_2^2) * (T(i) - T(i-1)) + sigma_1 * W1(:, i-1) + sigma_2 * W2(:, i-1));
    end
end