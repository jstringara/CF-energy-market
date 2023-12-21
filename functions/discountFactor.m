function r = discountFactor(DF, dates, T)
    % DF: vector of discount factors
    % dates: vector of dates of the discount factors
    % T: vector of dates of the cash flows

    r = interp1(dates, DF, T, 'linear', 'extrap');
end