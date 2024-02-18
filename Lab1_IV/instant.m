% Instantenious velocity
% Evgeny Kolonsky Feb 2024

close all
clear

%% Model

% geometrical parameters
L = 1270e-3;  dL = 5e-3;  % mm
l = 124.5e-3; dl = 0.1e-3; % mm
h = 16.0e-3; dh = .1e-3; % mm
g = 9.7949; % m/s2 - error is negligible
N = 236;

a =  g * h / L;
da = a * sum_errors(dL/L,  dh/h);

%% Experiment 0 - zero acceleration
% import measurements to vector t
url = "https://raw.githubusercontent.com/tphlabs/data/main/Lab1_IV/d000.txt"; % place here path to your data
data = readmatrix(url);
t = data(:,2); % time in column 2
count = data(:, 4); % counts B
figure(1)
plot(count, '.')
xlabel('Points')
ylabel('Kruze sensor counts')

% Cut parabola
ix0 = 1;
ix1 =5000;

t = t(ix0: ix1) - t(ix0);
count = count(ix0:ix1);
x = - count * l / N;

[a0, a0_err, ] = get_acc(t, x);


%% Experiment 1
% import measurements to vector t
url = "https://raw.githubusercontent.com/tphlabs/data/main/Lab1_IV/d160.txt"; % place here path to your data
data = readmatrix(url);
t = data(:,2); % time in column 2
count = data(:, 4); % counts B
figure(2)
plot(count, '.')
xlabel('Points')
ylabel('Kruze sensor counts')

% Cut parabola
ix0 = 105;
ix1 = 374;

t = t(ix0: ix1) - t(ix0);
count = count(ix0:ix1);
x = - count * l / N;

[a_fit, a_fit_err, v0_fit] = get_acc(t, x);
grid on

% Instant velocity as discrete derivative
n = 5;
dx = x(1 + 2*n: end) - x(1: end - 2*n);
dt = mean(diff(t));
v1 = dx ./ (2*n*dt);
t1 = t(1+n: end-n) + dt/2;

figure(4)
hold on
grid on
plot(t1*1e3, v1*1e3, '.')
xlabel('Time, ms')
ylabel('Velocity, mm/s')

v_fit = v0_fit + t * a_fit;
plot(t*1e3, v_fit*1e3)

v_theor = v0_fit + t * (a + a0);
plot(t*1e3, v_theor*1e3)

expected_text = sprintf('Expected a: \n %.1f ± %.1f mm/s2', (a + a0)*1e3, sum_errors(da, a0_err)*1e3);
fit_text      = sprintf('Fitted a: %.1f ± %.1f mm/s2', a_fit*1e3, a_fit_err*1e3);

legend('Derivative', fit_text, expected_text)

%% Friction coefficient as a difference of up and down acceleration 
middle = round(length(x) / 2);
xup = x(1:middle);
tup = t(1:middle);
xdown = x(middle:end);
tdown = t(middle:end);

[aup, aup_err, ] = get_acc(tup, xup);
[adown, adown_err, ] = get_acc(tdown, xdown);

mu = (aup - adown) / 2 / g;
mu_err = sum_errors(aup_err, adown_err) / g;
mu_text  = sprintf('mu: %.1e ± %.1e', mu, mu_err);

%% Functions
function [answer] = sum_errors(dx, dy)
    answer = sqrt(dx^2 + dy^2);
end

% get acceleration with 95% confidence interval and initial velocity 
% out of vectors t, x
function [acc, acc_err, v0] = get_acc(t, x)
    [model,goodness] = fit(t, x,'poly2');
    
    acc = model.p1 * 2;
    v0 = model.p2;
    
    ci = confint(model, 0.95); % confidence intervals
    acc_err = abs(ci(2,1) - ci(1,1)) / 2; % uncertainty of a

end
