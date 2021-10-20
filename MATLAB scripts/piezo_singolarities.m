%% Poles and Zeros
P = pole(tf1);
Z = zero(tf1);

%poles calculations
alpha_p = abs(real(P(2)));
wd_p = abs(imag(P(2)));

syms zeta_p
eqn = zeta_p/alpha_p == sqrt(1-(zeta_p)^2)/wd_p;
S1 = solve(eqn, zeta_p);
zeta_p = double(S1)

syms wn_p
eqn = wn_p == wd_p/sqrt(1-(zeta_p)^2);
S2 = solve(eqn, wn_p);
wn_p = double(S2);
fn_p = wn_p/(2*pi)

syms Q_p 
eqn = Q_p == 1 / (2 * zeta_p);
S = solve(eqn, Q_p);
Q_p = double(S)

%zeroes calculations
alpha_z = abs(real(Z(2)));
wd_z = abs(imag(Z(2)));

syms zeta_z
eqn = zeta_z/alpha_z == sqrt(1-(zeta_z)^2)/wd_z;
S1 = solve(eqn, zeta_z);
zeta_z = double(S1)

syms wn_z
eqn = wn_z == wd_z/sqrt(1-(zeta_z)^2);
S2 = solve(eqn, wn_z);
wn_z = double(S2);
fn_z = wn_z/(2*pi)

syms Q_z 
eqn = Q_z == 1 / (2 * zeta_p);
S = solve(eqn, Q_z);
Q_z = double(S)

%static gain
G = dcgain(tf1);

clear P Z alpha_P alpha_Z eqn S1 S2 S