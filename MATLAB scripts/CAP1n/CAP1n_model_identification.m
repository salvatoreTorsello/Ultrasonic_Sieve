clear; clc;

%% Import data

CAP1n = importData("C:\git\Ultrasonic_Sieve\Acquisitions\CAP1n\CAP1n_0_10.csv", [2, Inf]);
Ts = CAP1n.TIME(2) - CAP1n.TIME(1);
%% Data manipulation

%Elimination of last nan data
CAP1n = CAP1n(1:end-1,:);

%Creation of Vpiezo and Ipiezo channels
CAP1n.Vcap = CAP1n.Vgen - CAP1n.Vres;
CAP1n.Icap = CAP1n.Vres ./ 50;

%% System Identification

%Number of expected singularities
np = 1;
nz = 0;

opt = tfestOptions('Display','on');

%Loading of the data
CAP1n_data = iddata(CAP1n.Vcap, CAP1n.Icap, Ts);
CAP1n_tf = tfest(CAP1n_data,np, nz, opt);
CAP1n_tf = idtf(CAP1n_tf.num,CAP1n_tf.den);

%%
CAP1n_tf
P = pole(CAP1n_tf);
G = dcgain(CAP1n_tf);

Cap = 1 / (abs(P) * G)