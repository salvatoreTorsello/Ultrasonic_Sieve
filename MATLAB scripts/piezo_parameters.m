%% Tranfer Function upload
a = tf1.Numerator;
b = tf1.Denominator;

Cp = 2e-9;

syms L C R

eqn2 = R / (L * Cp)             == a(2);
eqn3 = 1 / (L * C * Cp)         == a(3);

eqn4 = R / L                    == b(2);
eqn5 = (C + Cp) / (L * C * Cp)  == b(3);

S = solve([eqn2, eqn3, eqn4, eqn5], [L, C, R]);