% Average velocity
% Evgeny Kolonsky Feb 2024

close all
clear
%% Experiment
% import measurements to vector t
url = "https://raw.githubusercontent.com/tphlabs/data/main/Lab1_AV/test.txt"; % place here path to your data
data = readmatrix(url);
t = data(:,2); % time in column 2
figure(1)
hold on
plot(t,'.')

mu = mean(t);
sigma = std(t);
N = length(t);
sigma_mu = sigma / sqrt(N);

% Chauvenet outlier rejection test
% in general case shoud be repeated interatively

% suspected_outlier and his index
[suspected, ix] = max(abs(t - mu)/sigma/sqrt(2));

P = (1 - cdf('normal', suspected)) + cdf('normal', -suspected);
% Chauvenet criterion value to be compared with 1/2
if N * P < .5
  % 'outlier: to be deleted'
  plot(ix, t(ix), 'rx')
  t(ix) = [];
  % new average and sigma
  mu = mean(t);
  sigma = std(t);
  N = N - 1;
  sigma_mu = sigma / sqrt(N);
end
hold off
legend('data', 'outlier')
xlabel('Measurements numbered')
ylabel('Cart passing gate time, s')


figure(2)
txt1 = sprintf('Measured average time: \n %.1f ± %.1f ms', mu*1e3, sigma_mu*1e3);
histfit(t * 1e3)
title(txt1)
xlabel('Cart passing gate time, ms')
ylabel('Events frequency')

%% Model

% geometrical parameters
L = 1272e-3;  dL = 10e-3;  % mm
l = 125e-3; dl = 1e-3; % mm
s0 = (402-145)*1e-3; ds0 = 2e-3; % mm
h = 13.8e-3; dh = .1e-3; % mm
g = 9.7949; dg = 1e-4; % m/s2 - error is negligible

s1 = s0 + l; ds1 = sum_errors(dl, ds0);


% Relative errors
eL = dL / L;
el = dl / l;
es0 = ds0 / s0;
es1 = ds1 / s1;
eh = dh / h;

% acceleration
a = g * h / L;
ea = sum_errors(eh,  eL);

% time 
t0 = sqrt(2 * s0 /a);
et0 = sum_errors(es0, ea)/2;
dt0 = t0 * et0;

t1 = sqrt(2 * s1 /a);
et1 = sum_errors(es1, ea)/2;
dt1 = t1 * et1;

deltat = t1 - t0;
ddeltat = sum_errors(dt1, dt0);
edeltat = ddeltat /  deltat;

txt2= sprintf('Expected time: \n %.0f ± %.0f ms', deltat*1e3, ddeltat*1e3);

function [answer] = sum_errors(dx, dy)
    answer = sqrt(dx^2 + dy^2);
end