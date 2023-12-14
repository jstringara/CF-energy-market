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

%% Calibration

F0 = table_swaps(end, end).Variables; % swap price at time 0
K = table_options(1, 2:end).Variables; % strike prices
T = table_options(2:end, 1).Variables; % maturities
r = rate_ois(table_ois, T); % OIS rate


market_prices = table_options(2:end, 2:end).Variables; % real market prices

% Calibration of the model
% we use fmincon to minimize the error between the market prices and the
% model prices

% error function is the mse between the market prices and the model prices
func = @(x) mean(mean( (market_prices - price_swaption_batch(F0, K, T, r, x(1), x(2))).^2));
% initial guess, random number between 0.01 and 1
x0 = rand(1, 2) * 0.99 + 0.01;

% lower bounds (variance must be stricly positive)
lb = [0.01, 0.01];

[x, fval] = fmincon(func, x0, [], [], [], [], lb)

%% Plot the calibration

% Plot the market prices
figure; 
hold on
surf(K, T, market_prices);
xlabel('Strike price');
ylabel('Maturity');
zlabel('Market price');
title('Market prices of swaptions');

% Plot the model prices
surf(K, T, price_swaption_batch(F0, K, T, r, x(1), x(2)))
zlabel('Model price')

legend('Market price', 'Model price')

view(3)