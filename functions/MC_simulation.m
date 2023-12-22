function Simulations = MC_simulation(sigma_int_inc, F0, T)
    % sigma must be a timedependent function of t

    N_sim = 10000;

    Simulations = zeros(N_sim, length(T)+1);

    Simulations(:,1) = F0;

    for t = 1:length(T)
        % drift condition, int A = -1/2 * sigma^2
        drift = -1/2 * sigma_int_inc(t);
        % sum of two normal is a normal of mean = sum of means
        % and variance = sum of variances
        % stochastic integral is approximated as a normal
        % of mean zero and variance sigma(t)
        stoc_int = randn(N_sim,1) * sqrt(sigma_int_inc(t));

        Simulations(:,t+1) = Simulations(:,t) .* exp(drift + stoc_int);
    end

end