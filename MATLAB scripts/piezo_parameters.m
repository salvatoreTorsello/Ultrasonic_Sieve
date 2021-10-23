%% Parameters estimation
Cp = 5.5e-9;

syms L C

eqn1 = wn_p^2 == (C + Cp)/(L * C * Cp);
eqn2 = wn_z^2 == 1 / (L * C);

S = solve([eqn1, eqn2], [L, C]);
L = double(S.L)
C = double(S.C)

syms R

eqn = R / L == 2* zeta_p* wn_p;
S = solve(eqn, R);
R = double(S)

clear a b eqn1 eqn2 eqn S