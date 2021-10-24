tf1
P = pole(tf1);

Rp = dcgain(tf1);

Cp = 1 / (Rp * P);
