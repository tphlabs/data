import numpy as np

m1 = 213.2e-3

d = 0.1e-3

m_k1 = 17.4e-3
m_k2 = 17.3e-3

dk1 = d/m_k1
dk2 = d/m_k2

Dm_k1 = 42.6e-3
Dm_k2 = 43.1e-3

L = 97.95e-3  #m

g = 9.795

k1 = Dm_k1*g/L
k2 = Dm_k2*g/L

def err_sum(d1, d2):
    return np.sqrt(d1**2+d2**2)
    

omega_0 = np.sqrt((k1+k2)/m1)

domega_0 = err_sum(dk1,dk2) 

print(f'Nat frequency expected = {omega_0:.3f} +-{domega_0:.3f} rad/s')
#print(f'e=Err frequency expected = {domega_0:.3} rad/s')