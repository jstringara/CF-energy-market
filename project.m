%% Clear workspace

close all
clear all
warning('off','all')

% fix the seed of the random number generator
rng("default");

clc

%% Load the data

data_dir = "Data/";

% Load the data from the DEEEX.xlsx file
table_swaps = readtable(data_dir + "DataDEEEX.xlsx", 'Sheet', 'F');
table_options = readtable(data_dir + "DataDEEEX.xlsx", 'Sheet', 'OptionsONQ42024');
table_ois = readtable(data_dir + "DataDEEEX.xlsx", 'Sheet', 'ois');

% add functions to the path
addpath("functions/");

%% Dates of discount factors
number_days = 365; % number of days in a year
dates = table_ois(1, 1:end).Variables + 693960; % dates + adjustment to matlab date format

% take differences between the dates and today (04/11/2023)
% we need to convert the dates to datenum format
dates = dates - datenum('04/11/2023', 'dd/mm/yyyy');
dates = dates / number_days; % convert to fraction of (business) year

%% Discount factors
OIS_DF = table_ois(2, 1:end).Variables; % discount factors
% figure; hold on
% plot(dates, OIS_DF);
% xlabel('Time (years)');
% ylabel('Discount factor');
% title('Discount factors');

%% Calibration set-up

F0 = table_swaps(end, end).Variables; % swap price at time 0
K = table_options(1, 2:end).Variables; % strike prices
T = table_options(2:end, 1).Variables; % maturities
DF = discountFactor(OIS_DF, dates, T); % discount factors at the maturities of the options
volatilities = table_options(2:end, 2:end).Variables; % real market implied volatilities
max_volatility = max(volatilities, [], "all"); % maximum volatility
% convert the volatilities to sigma hat (volatility * sqrt(T))
market_sigma_hat = volatilities .* repmat(sqrt(T), 1, length(K));
market_prices = volsToPrices(F0, K, T, DF, volatilities); % market prices of the options
% expiry of the swap
T1 = datenum(table_swaps(end, 1).Variables);
T1 = T1 - datenum('04/11/2023', 'dd/mm/yyyy');
T1 = T1 / number_days; % convert to fraction of (business) year
% maturity of the swap
T2 = datenum('31/12/2024', 'dd/mm/yyyy');
T2 = T2 - datenum('04/11/2023', 'dd/mm/yyyy');
T2 = T2 / number_days; % convert to fraction of (business) year


%% Point III: Calibrate the model using the Black-76 formula

% Use the MSE as error function
func = @(x) MSE(market_prices, constantVolatilitySwaption(x(1), x(2), F0, K, T, DF));

lb = [0, 0]; % lower bounds (variance must be stricly positive)

% initial guess, two random numbers between 0 and 1
x0 = max_volatility * rand(1, 2);

% use fmincon to minimize the error function
[x_const, fval_const] = fmincon(func, x0, [], [], [], [], lb)

%% Plot the calibration

% prepare the data for the plot

% compute the model prices and volatilities
[model_prices_const, model_volatilities_const] = constantVolatilitySwaption( ...
    x_const(1), x_const(2), F0, K, T, DF);

% plot sigma hat
figure; hold on
% plot the market volatilities using only shades of red
surf(K, T, market_sigma_hat, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
% Plot the model volatilities (using only shades of blue)
surf(K, T, model_volatilities_const, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market \hat\sigma', 'Model \hat\sigma')
xlabel('Strike price'); ylabel('Maturity'); zlabel('\hat\sigma');
title('\hat\sigma of swaptions');
view(45,20);

% second subplot: plot the prices
figure; hold on
% plot the market prices using only shades of red
surf(K, T, market_prices, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
% Plot the model prices (using only shades of blue)
surf(K, T, model_prices_const, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market price', 'Model price');
xlabel('Strike price'); ylabel('Maturity'); zlabel('Swaption Price')
title('Prices of swaptions');
view(45,20)

figure; hold on
% plot the volatilities directly
surf(K, T, volatilities);
surf(K,T, sqrt(x_const(1)^2 + x_const(2)^2) * ones(size(volatilities)));
legend('Market volatility', 'Model volatility')
xlabel('Strike price'); ylabel('Maturity'); zlabel('Volatility');
title('Volatilities of swaptions');
view(45,20);

%% Point IV: Calibration with time-dependent volatility

% Use the MSE as error function
func = @(x) MSE(market_prices, singleTimeDependentVolatilitySwaption(x(1:end-1), x(end), F0, K, T, DF));

% lower bounds (variances must be stricly positive, alpha must be stricly positive)
lb = zeros(length(T)+1, 1);

% initial guess, length(T)+1 random numbers between 0 and 1
x0 = max_volatility * rand(length(T)+1, 1);

% use fmincon to minimize the error function
[x_singletime, fval_singletime] = fmincon(func, x0, [], [], [], [], lb)

%% Plot the calibration

% compute the model prices
[model_prices_singletime, model_volatilities_singletime] = singleTimeDependentVolatilitySwaption( ...
    x_singletime(1:end-1), x_singletime(end), F0, K, T, DF);

% sigma hats
figure; hold on
surf(K, T, market_sigma_hat, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
surf(K, T, model_volatilities_singletime, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market \hat\sigma', 'Model \hat\sigma')
xlabel('Strike price'); ylabel('Maturity'); zlabel('\hat\sigma');
title('\hat\sigma of swaptions');
view(45,20);

% prices
figure; hold on
surf(K, T, market_prices, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
surf(K, T, model_prices_singletime, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market price', 'Model price');
xlabel('Strike price'); ylabel('Maturity'); zlabel('Swaption Price')
title('Prices of swaptions');
view(45,20);

%% Point V: Calibration with two time-dependent volatilities

% Use the MSE as error function
func = @(x) MSE(market_prices, timeDependentVolatilitySwaption(x(:,1), x(:,2), F0, K, T, DF));

% lower bounds (variances must be stricly positive, alpha must be stricly positive)
lb = zeros(length(T), 2);

% initial guess, three random numbers between 0 and 1
x0 = max_volatility * rand(length(T), 2);

% use fmincon to minimize the error function
[x_time, fval_time] = fmincon(func, x0, [], [], [], [], lb)

%% Plot the calibration

% compute the model prices
[model_prices_time, model_volatilities_time] = timeDependentVolatilitySwaption(...
    x_time(:,1), x_time(:,2), F0, K, T, DF);


% sigma hats
figure; hold on
surf(K, T, market_sigma_hat, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
surf(K, T, model_volatilities_time, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market \hat\sigma', 'Model \hat\sigma')
xlabel('Strike price'); ylabel('Maturity'); zlabel('\hat\sigma');
title('\hat\sigma of swaptions');
view(45,20);

% prices
figure; hold on
surf(K, T, market_prices, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
surf(K, T, model_prices_time, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market price', 'Model price');
xlabel('Strike price'); ylabel('Maturity'); zlabel('Swaption Price')
title('Prices of swaptions');
view(45,20);

%% Point VI: Calibration with deterministic volatilities

% Use the MSE as error function
func = @(x) MSE(market_prices, deterministicVolatilitySwaption( ...
    x(1), x(2), x(3), x(4), T1, T2, F0, K, T, DF));

% lower bounds (variances must be stricly positive, alpha must be stricly positive)
lb = zeros(4, 1);

% initial guess, sigmas are betweeen 0 and max_volatility, alphas are between 1 and 2
x0 = [max_volatility * rand(1,1), rand(1,1)+1, max_volatility*rand(1,1), rand(1,1)+1];

% use fmincon to minimize the error function
[x_det, fval_det] = fmincon(func, x0, [], [], [], [], lb)

%% Plot the calibration

% compute the model prices
[model_prices_det, model_volatilities_det] = deterministicVolatilitySwaption( ...
    x_det(1), x_det(2), x_det(3), x_det(4), T1, T2, F0, K, T, DF);

% sigma hats
figure; hold on
surf(K, T, market_sigma_hat, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
surf(K, T, model_volatilities_det, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market \hat\sigma', 'Model \hat\sigma')
xlabel('Strike price'); ylabel('Maturity'); zlabel('\hat\sigma');
title('\hat\sigma of swaptions');
view(45,20);

% prices
figure; hold on
surf(K, T, market_prices, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
surf(K, T, model_prices_det, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market price', 'Model price');
xlabel('Strike price'); ylabel('Maturity'); zlabel('Swaption Price')
title('Prices of swaptions');
view(45,20);

%% Point VII, a: pricing a down-and-in call option, using the constant volatility model

sigma_hat = sqrt((x_const(1)^2 + x_const(2)^2) * T(end)); % sigma
L = 450; % barrier
K = 500; % strike

C_DI_const = downAndInCallOptionPrice(F0, K, L, T(end), DF(end), sigma_hat)

%% Prova del nove

% integral is (sigma_1^2 + sigma_2^2) * (T_n - T_{n-1})
sigma_int_inc = (x_const(1)^2 + x_const(2)^2) * (T - [0; T(1:end-1)]);

Sim_const = MC_simulation(sigma_int_inc, F0, T);

% find which rows have gone below the barrier
below_barrier = Sim_const < L;
below_barrier = any(below_barrier, 2);

C_DI_const_MC = max(Sim_const(:,end) - K, 0) .* below_barrier;

C_DI_const_MC = mean(C_DI_const_MC) * DF(end)