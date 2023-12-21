%% Clear workspace

close all
clear all
warning('off','all')
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
x0 = 10 * rand(1, 2);

% use fmincon to minimize the error function
[x_const, fval_const] = fmincon(func, x0, [], [], [], [], lb)

%% Plot the calibration

% prepare the data for the plot

% compute the model prices and volatilities
[model_prices_const, model_volatilities_const] = constantVolatilitySwaption( ...
    x_const(1), x_const(2), F0, K, T, DF);

figure('Name', 'Calibration with constant volatilities');

% first subplot: plot the volatilities
subplot(1, 2, 1); hold on
% plot the market volatilities using only shades of red
surf(K, T, volatilities, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
% Plot the model volatilities (using only shades of blue)
surf(K, T, model_volatilities_const, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market volatility', 'Model volatility')
xlabel('Strike price'); ylabel('Maturity'); zlabel('Volatility');
title('Volatilities of swaptions');
view(45,20);

% second subplot: plot the prices
subplot(1, 2, 2); hold on
% plot the market prices using only shades of red
surf(K, T, market_prices, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
% Plot the model prices (using only shades of blue)
surf(K, T, model_prices_const, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market price', 'Model price');
xlabel('Strike price'); ylabel('Maturity'); zlabel('Swaption Price')
title('Prices of swaptions');
view(45,20)

%% Point IV: Calibration with time-dependent volatility

% Use the MSE as error function
func = @(x) MSE(market_prices, singleTimeDependentVolatilitySwaption(x, F0, K, T, DF));

% lower bounds (variances must be stricly positive, alpha must be stricly positive)
lb = zeros(size(T));

% initial guess, length(T)+1 random numbers between 0 and 1
x0 = rand(size(T));

% use fmincon to minimize the error function
[x_singletime, fval_singletime] = fmincon(func, x0, [], [], [], [], lb)

%% Plot the calibration

% compute the model prices
[model_prices_singletime, model_volatilities_singletime] = singleTimeDependentVolatilitySwaption( ...
    x_singletime, F0, K, T, DF);

% Plot the market prices
figure('Name', 'Calibration with single time-dependent volatility');

% volatilities
subplot(1, 2, 1); hold on
surf(K, T, volatilities, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
surf(K, T, model_volatilities_singletime, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market volatility', 'Model volatility')
xlabel('Strike price'); ylabel('Maturity'); zlabel('Volatility');
title('Volatilities of swaptions');
view(45,20);

% prices
subplot(1, 2, 2); hold on
surf(K, T, market_prices, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
surf(K, T, model_prices_singletime, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');

legend('Market price', 'Model price');
xlabel('Strike price'); ylabel('Maturity'); zlabel('Swaption Price')
title('Prices of swaptions');
view(45,20);

%% Point V: Calibration with two time-dependent volatilities

% Use the MSE as error function
func = @(x) MSE(market_prices, timeDependentVolatilitySwaption(x(1), x(2), x(3), x(4), F0, K, T, DF, T1, T2));

% lower bounds (variances must be stricly positive, alpha must be stricly positive)
lb = [0, 0, 0, 0];
ub = [1, 10, 1, 10];

% initial guess, three random numbers between 0 and 1
x0 = rand(1, 4);

% use fmincon to minimize the error function
[x, fval] = fmincon(func, x0, [], [], [], [], lb, ub)

%% Plot the calibration

% compute the model prices
model_prices = timeDependentVolatilitySwaption(x(1), x(2), x(3), x(4), F0, K, T, DF, T1, T2);

% Plot the market prices
figure;
hold on
% plot the market prices using only shades of red
surf(K, T, market_prices, 'FaceColor', [1 0.5 0.5], 'EdgeColor', 'none');
xlabel('Strike price');
ylabel('Maturity');
zlabel('Market price');
title('Market prices of swaptions');

% Plot the model prices
surf(K, T, model_prices, 'FaceColor', [0.5 0.5 1], 'EdgeColor', 'none');
zlabel('Model price')

legend('Market price', 'Model price')

view(45,20)