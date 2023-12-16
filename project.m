%% Load the data

close all
clear all
clc
warning('off','all')

data_dir = "Data/";

% Load the data from the DEEEX.xlsx file
table_swaps = readtable(data_dir + "DataDEEEX.xlsx", 'Sheet', 'F');
table_options = readtable(data_dir + "DataDEEEX.xlsx", 'Sheet', 'OptionsONQ42024');
table_ois = readtable(data_dir + "DataDEEEX.xlsx", 'Sheet', 'ois');

%% Dates of discount factors
dates = table_ois(1, 1:end).Variables + 693960; % dates + adjustment to matlab date format

% take differences between the dates and today (04/11/2023)
% we need to convert the dates to datenum format
dates = dates - datenum('04/11/2023', 'dd/mm/yyyy');
dates = dates / 365; % convert to fraction of (business) year

%% Discount factors
OIS_DF = table_ois(2, 1:end).Variables; % discount factors
figure; hold on
plot(dates, OIS_DF);
xlabel('Time (years)');
ylabel('Discount factor');
title('Discount factors');

%% Point III: Calibration with constant volatility

F0 = table_swaps(end, end).Variables; % swap price at time 0
K = table_options(1, 2:end).Variables; % strike prices
T = table_options(2:end, 1).Variables; % maturities
DF = discountFactor(OIS_DF, dates, T); % discount factors at the maturities of the options
market_prices = table_options(2:end, 2:end).Variables; % real market prices

%% Calibrate the model using the Black-76 formula

% Use the MSE as error function
func = @(x) mean(mean( (market_prices - constantVolatilitySwaption(x(1), x(2), F0, K, T, DF)).^2 ));

lb = [0, 0]; % lower bounds (variance must be stricly positive)

% initial guess, two random numbers between 0 and 1
x0 = rand(1, 2);

% use fmincon to minimize the error function
[x, fval] = fmincon(func, x0, [], [], [], [], lb)

%% Plot the calibration

% compute the model prices
model_prices = constantVolatilitySwaption(x(1), x(2), F0, K, T, DF);

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

view(-30, 30)

%% Point IV: Calibration with time-dependent volatility

% expiry of the swap
T1 = datenum(table_swaps(end, 1).Variables)
T1 = T1 - datenum('04/11/2023', 'dd/mm/yyyy');
T1 = T1 / 365; % convert to fraction of (business) year

% Use the MSE as error function
func = @(x) mean(mean( (market_prices - timeDependentVolatilitySwaption(x(1), x(2), x(3), F0, K, T, DF, T1)).^2 ));

% lower bounds (variances must be stricly positive, alpha must be stricly positive)
lb = [0, 0, 0];
ub = [Inf, 5, Inf];

% initial guess, three random numbers between 0 and 1
x0 = rand(1, 3);

% use fmincon to minimize the error function
[x, fval] = fmincon(func, x0, [], [], [], [], lb, ub)

%% Plot the calibration

% compute the model prices
model_prices = timeDependentVolatilitySwaption(x(1), x(2), x(3), F0, K, T, DF, T1);

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

view(-30, 30)