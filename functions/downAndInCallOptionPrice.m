function C_DI = downAndInCallOptionPrice(F0, K, L, T, DF, sigma)
    r = -log(DF)/T;
    r_tilde = r - sigma^2 / 2; % drift
    
    C_vanilla = Black76(L^2/F0, K, T, DF, sigma);

    C_DI = (L/F0)^(2*r_tilde/sigma^2) * C_vanilla;

end