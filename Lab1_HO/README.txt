Set #13
M = 214.84e-3;
m1 = 12.13e-3;
m2 = 17.47e-3;
g = 9.7949;
l = 97.95e-3;
w1 = 60.06e-3;
w2 = 42.925e-3;
k1 = w1 * g / l;
k2 = w2 * g / l;
m_eff = M + (m1 + m2)/3;
k_eff = k1 + k2;
omega0 = sqrt(k_eff / m_eff);
N = 236;
L = 125e-3;
