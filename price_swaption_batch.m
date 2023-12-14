function C = price_swaption_batch(F0,K,T,r,sigma_1, sigma_2)
    % here T and K are vectors
    % we return a matrix C of size length(T) x length(K)
    C = zeros(length(T),length(K));

    for i = 1:length(T)
        for j = 1:length(K)
            C(i,j) = price_swaption(F0,K(j),T(i),r,sigma_1, sigma_2);
        end
    end

end
