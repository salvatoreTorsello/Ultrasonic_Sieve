%%
US2_100_woC_woS = US2_100_woC_woS(1:end-1,:);
US2_100_woC_woS.Vpiezo = US2_100_woC_woS.Vgen - US2_100_woC_woS.Vres;
US2_100_woC_woS.Ipiezo = US2_100_woC_woS.Vres ./ 50;

%%
US2_1_woC_woS = US2_1_woC_woS(1:end-1,:);
US2_1_woC_woS.Vpiezo = US2_1_woC_woS.Vgen - US2_1_woC_woS.Vres;
US2_1_woC_woS.Ipiezo = US2_1_woC_woS.Vres ./ 50;

%%
US2_5_woC_woS = US2_5_woC_woS(1:end-1,:);
US2_5_woC_woS.Vpiezo = US2_5_woC_woS.Vgen - US2_5_woC_woS.Vres;
US2_5_woC_woS.Ipiezo = US2_5_woC_woS.Vres ./ 50;

%%
systemIdentification;

%%
US3_0_10_woC_woS_tf1
P = pole(US3_0_10_woC_woS_tf1);
G = dcgain(US3_0_10_woC_woS_tf1);

Cp = 1 / (abs(P) * G)

%%
US2_tf1
P = pole(US2_tf1);
G = dcgain(US2_tf1);

Cp = 1 / (abs(P) * G)


