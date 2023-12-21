function MSE = MSE(y, y_hat)
    % Calculate the mean squared error between the two matrices y and y_hat of the same size
    %
    % Inputs:
    %   y: the true values
    %   y_hat: the predicted values
    %
    % Output:
    %   MSE: the mean squared error between the two matrices y and y_hat

    % check if the two matrices have the same size
    if size(y) ~= size(y_hat)
        error('The two matrices must have the same size');
    end

    % calculate the mean squared error
    MSE = mean((y - y_hat).^2, "all");
end