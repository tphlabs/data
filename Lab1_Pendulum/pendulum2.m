% Pendulum
% Evgeny Kolonsky Jan 2024
clear 
close all
%%

% Errors
T10_err = 0.5; % s human reaction error
L_err = 10; % mm, uncertainty in length measurements
theta_err0 = 5; % grad, uncertainty in angle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment 1:  T(theta)
% l = 80 cm
theta = [5 10 20 35 30 35 40 50 60 70 80];
theta_err = theta_err0 * ones(11,1);
T10 = [14.37 14.52 14.62 14.69 14.66 14.76 14.88 15.08 15.28 15.53 16.22];
N = 10;
T = T10 / N ;
T_err = T10_err/10 * ones(11,1); % err / 10
figure(1)
errorbar(theta, T, T_err, T_err, theta_err, theta_err, 'o')
xlabel('Angular amplitude, [grad]')
ylabel('Oscillations period, [s]')
legend('measurements')
grid on
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Experiment 2: T(l)
% Theta <= 30 grad

% Place measurements with errobars on the same graph with model
% T ~ sqrt(l)
figure(2)

l = [508 480 432 410 332 303 330 370 420 462]; % mm
T10 = [14.62 14.09 13.39 13.02 11.65 11.22 11.78 12.63 13.19 13.83]; % s
delta_l = L_err ./ l; % relative error
delta_T = T10_err ./ T10; % relative error
Tmax = T(1); 
lmax = l(1);

% before applying logarythm we have to unitless
T_unitless = T10 ./ Tmax / 10;
l_unitless = l / lmax;
% errors in unitless T and l: the same error for all points
T_u_err = T10_err /10 /Tmax * ones(10,1);
l_u_err = L_err /lmax * ones(10,1);

% array of points on l axis to build estimated curve
l_expected = linspace(0, max(l_unitless));
T_expected = sqrt(l_expected);

hold on
errorbar(l_unitless, T_unitless, T_u_err, T_u_err, l_u_err, l_u_err, '.')
plot(l_expected, T_expected)
legend('measurements', 'expected alpha=0.5')

xlabel('L/Lmax')
ylabel('T/Tmax')
grid on
hold off



%% ln axis


% Place measurements with errobars on log axis
% and build linear regression
figure(3)

Tmax = T10(1);
lmax = l(1);
lnT = log(T10/Tmax);
lnl = log(l/lmax);

lnT_err = delta_T ./ (T10 / Tmax);
lnl_err = delta_l ./ (l / lmax);

hold on
% measurements with error bars
errorbar(lnl, lnT, lnT_err, lnT_err, lnl_err, lnl_err, 'o')

% linear regression with intercept = 0
linear_regression = fitlm(lnl,lnT, 'Intercept',false);
R_squared = linear_regression.Rsquared.Ordinary;
a_coefficient = linear_regression.Coefficients.Estimate(1);
a_error = linear_regression.Coefficients.SE(1);
fit_text = sprintf('alpha = %.2f ± %.2f', a_coefficient, a_error);

plot(lnl,linear_regression.Fitted,'k');

legend('measurements', fit_text)

xlabel('log L/Lmax')
ylabel('log T/Tmax')
grid on
hold off

