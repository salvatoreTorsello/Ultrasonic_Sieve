%% Method 1 System Identification for Cp calculation %%

US3 = importData("C:\git\Ultrasonic_Sieve\Acquisitions\US3\US3_0_10_woC_woS.csv", [2, Inf]);
Ts = US3.TIME(2) - US3.TIME(1);

%%%% Data manipulation %%%%

%Elimination of last NaN data
US3 = US3(1:end-1,:);

%Creation of Vpiezo and Ipiezo channels
US3.Vpiezo = US3.Vgen - US3.Vres;
US3.Ipiezo = US3.Vres ./ 50;

%Number of expected singularities
np = 1;
nz = 0;

opt = tfestOptions('Display','on');

%Loading of the data
US3_data = iddata(US3.Vpiezo, US3.Ipiezo, Ts);
US3_tf = tfest(US3_data,np, nz, opt);
US3_tf = idtf(US3_tf.num,US3_tf.den);

% US3_param.Cp_est calculation

US3_tf
P = pole(US3_tf);
G = dcgain(US3_tf);

US3_woC.Cp_est = 1 / (abs(P) * G)

%% Clear worlspace
clear US3_tf P G US3_data np nz US3 opt Ts