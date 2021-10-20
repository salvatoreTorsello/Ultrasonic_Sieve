%% Poles and Zeros
P = pole(tf1);
Z = zero(tf1);

alpha_p = abs(real(P(2)));
wd_p = abs(imag(P(2)));

alpha_z = abs(real(Z(2)));
wd_z = abs(imag(Z(2)));

syms zeta_p
eqn1 = zeta_p/alpha_p == sqrt(1-(zeta_p)^2)/wd_p;
S1 = solve(eqn1, zeta_p);
zeta_p = double(S1);

syms wn_p
eqn2 = wn_p == wd_p/sqrt(1-(zeta_p)^2);
S2 = solve(eqn2, wn_p);
wn_p = double(S2);
fn_p = wn_p/(2*pi);

syms zeta_z
eqn1 = zeta_z/alpha_z == sqrt(1-(zeta_z)^2)/wd_z;
S1 = solve(eqn1, zeta_z);
zeta_z = double(S1);

syms wn_z
eqn2 = wn_z == wd_z/sqrt(1-(zeta_z)^2);
S2 = solve(eqn2, wn_z);
wn_z = double(S2);
fn_z = wn_z/(2*pi);

G = dcgain(tf1);

