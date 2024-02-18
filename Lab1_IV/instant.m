% Instantenious velocity
% Evgeny Kolonsky Feb 2024

close all
clear

%% Model

% geometrical parameters
L = 1270e-3;  dL = 5e-3;  % mm
l = 124.5e-3; dl = 0.1e-3; % mm
h = 16.0e-3; dh = .1e-3; % mm
g = 9.7949; dg = 0.0001; % m/s2 - error is negligible
N = 236;

a =  g * h / L;
da = a * sum_errors(dL/L,  dh/h);

%% import measurements and cut parabola
url = "https://raw.githubusercontent.com/tphlabs/data/main/Lab1_IV/d160.txt"; % place here path to your data
data = readmatrix(url);
t = data(:,2); % time in column 2
count = data(:, 4); % counts B
figure(1)
plot(count, '.')
xlabel('Points')
ylabel('Kruze sensor counts')

% Cut parabola
ix0 = 120;
ix1 = 374;

t = t(ix0: ix1) - t(ix0);
count = count(ix0:ix1);
x = - count * l / N;

%% fit parabola

figure(2)
hold on
grid on
[a1, a1_err, model] = get_accx(t, x);

a1txt = valuetxt('a1', a1*1e3,  a1_err*1e3, 'mm/s2');
plot(t, x, 'b.')
plot(model)
xlabel('time, ,s')
ylabel('Displacement, mm')
legend('Kruze data', a1txt)

%% Instant velocity as discrete derivative with different n
figure(3)
subplot(3,1,1)
n = 1;
hold on
grid on
[t1, v1] = get_derivative(t, x, n);
[a2, a2_err, model] = get_accv(t1, v1);
a2txt = valuetxt('a2', a2*1e3,  a2_err*1e3, 'mm/s2');
plot(t1, v1, '.')
plot(model)
xlabel('Time, ms')
ylabel('Velocity, m/s')
legend(sprintf('n=%d',n), a2txt)

subplot(3,1,2)
n = 2;
hold on
grid on
[t1, v1] = get_derivative(t, x, n);
[a2, a2_err, model] = get_accv(t1, v1);
a2txt = valuetxt('a2', a2*1e3,  a2_err*1e3, 'mm/s2');
plot(t1, v1, '.')
plot(model)
xlabel('Time, ms')
ylabel('Velocity, m/s')
legend(sprintf('n=%d',n), a2txt)

subplot(3,1,3)
n = 5;
hold on
grid on
[t1, v1] = get_derivative(t, x, n);
[a2, a2_err, model] = get_accv(t1, v1);
a2txt = valuetxt('a2', a2*1e3,  a2_err*1e3, 'mm/s2');
plot(t1, v1, '.')
plot(model)
xlabel('Time, ms')
ylabel('Velocity, m/s')
legend(sprintf('n=%d',n), a2txt)


%% Friction coefficient as a difference of up and down acceleration 
middle = round(length(x) / 2);
xup = x(middle:-1:1); % revert direction to start from peak and go down
tup = t(middle:-1:1);
xdown = x(middle:end); % keep direction from peak and go down
tdown = t(middle:end);

[aup, aup_err, modelup] = get_accx(tup, xup);
auptxt = valuetxt('aup', aup*1e3,  aup_err*1e3, 'mm/s2');
[adown, adown_err, modeldown] = get_accx(tdown, xdown);
adowntxt = valuetxt('adown', adown*1e3,  adown_err*1e3, 'mm/s2');

mu = (aup - adown) / 2 / g;
mu_err = sum_errors(aup_err, adown_err) / g;
mu_err = mu * sum_errors(mu_err/mu, dg);
mu_text  = sprintf('mu: %.1e ± %.1e', mu, mu_err);
figure(4)
hold on
grid on
plot(modelup, 'blue', 'predfunc', 0.95)
plot(modeldown, 'green', 'predfunc', 0.95)
legend(auptxt, adowntxt)


%% Functions
function [answer] = sum_errors(dx, dy)
    answer = sqrt(dx^2 + dy^2);
end

% get acceleration with 95% confidence interval
% out ov vectors t, x
function [acc, acc_err, model] = get_accx(t, x)
    model = fit(t, x,'poly2');
    acc = model.p1 * 2;
    ci = confint(model, 0.95); % confidence intervals
    acc_err = abs(ci(2,1) - ci(1,1)); % uncertainty of acc
end

% get acceleration with 95% confidence interval
% out of vectors t, v
function [acc, acc_err, model] = get_accv(t, v)
    model = fit(t, v,'poly1');
    acc = model.p1;
    ci = confint(model, 0.95); % confidence intervals
    acc_err = abs(ci(2,1) - ci(1,1)) /2 ; % uncertainty of acc
end

% get first discrete derivative with parameter n
function [t1, v1] = get_derivative(t, x, n)
    dx = x(1 + 2*n: end) - x(1: end - 2*n);
    dt = mean(diff(t));
    v1 = dx ./ (2*n*dt);
    t1 = t(1+n: end-n) + dt/2;
end

% format value and error
function [answer] = valuetxt(comment, value, error, units)
    answer = sprintf('%s: %.1f ± %.1f %s', comment, value, error, units);
end