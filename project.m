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

%% Discount Factors
DF = table_ois(2, 1:end).Variables; % discount factors
dates = table_ois(1, 1:end).Variables; % dates

% take differences between the dates and today (04/11/2023)
% we need to convert the dates to datenum format
dates = dates - datenum('04/11/2023', 'dd/mm/yyyy');
dates = dates / 365;

%% Calibration

F0 = table_swaps(end, end).Variables; % swap price at time 0
K = table_options(1, 2:end).Variables; % strike prices
T = table_options(2:end, 1).Variables; % maturities
r = 0.01 * ones(size(T)); % risk free rate

%% Monte Carlo simulation with constant volatilities

% Parameters
N_sim = 10000; % number of simulations
% Simulate the two brownian motions with N_sim paths and T time steps
W1 = randn(N_sim, length(T)-1);
W2 = randn(N_sim, length(T)-1);

% Change the variance at each time step to be Tn - Tn-1
% Each W ~ N(0,1), so we make it N(0, Tn - Tn-1)
for i = 2:length(T)
    W1(:, i) = W1(:, i) * sqrt(T(i) - T(i-1));
    W2(:, i) = W2(:, i) * sqrt(T(i) - T(i-1));
end

market_prices = table_options(2:end, 2:end).Variables; % real market prices

% error function is the mse between the market prices and the model prices
func = @(x) mean(mean( (market_prices - price_swaption_MC(F0, K, T, r, x(1), x(2), N_sim, W1, W2)).^2));

% Calibration of the model
% we use fmincon to minimize the error between the market prices and the
% model prices

% initial guess, random number between 0.01 and 1
x0 = rand(1, 2) * 0.99 + 0.01;

% lower bounds (variance must be stricly positive)
lb = [0.01, 0.01];

[x, fval] = fmincon(func, x0, [], [], [], [], lb)

%% Plot the calibration

% compute the model prices

model_prices = price_swaption_MC(F0, K, T, r, x(1), x(2), N_sim, W1, W2);

% Plot the market prices
figure; 
hold on
% plot the market prices using only shades of red
surf(K, T, market_prices);
xlabel('Strike price');
ylabel('Maturity');
zlabel('Market price');
title('Market prices of swaptions');

% Plot the model prices
surf(K, T, model_prices);
zlabel('Model price')

legend('Market price', 'Model price')

view(3)