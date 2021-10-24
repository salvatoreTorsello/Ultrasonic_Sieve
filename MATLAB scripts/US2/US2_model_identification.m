clear; clc;

%% System Identification for Cp calculation %%

US2 = importData("C:\git\Ultrasonic_Sieve\Acquisitions\US2\US2_0_10_woC_woS.csv", [2, Inf]);
Ts = US2.TIME(2) - US2.TIME(1);

%%%% Data manipulation %%%%

%Elimination of last nan data
US2 = US2(1:end-1,:);

%Creation of Vpiezo and Ipiezo channels
US2.Vpiezo = US2.Vgen - US2.Vres;
US2.Ipiezo = US2.Vres ./ 50;

%Number of expected singularities
np = 1;
nz = 0;

opt = tfestOptions('Display','on');

%Loading of the data
US2_data = iddata(US2.Vpiezo, US2.Ipiezo, Ts);
US2_tf = tfest(US2_data,np, nz, opt);
US2_tf = idtf(US2_tf.num,US2_tf.den);

% Cp calculation

US2_tf
P = pole(US2_tf);
G = dcgain(US2_tf);

Cp = 1 / (abs(P) * G)

%% System Identification for R L C calculation %%

US2_20_40 = importData("C:\git\Ultrasonic_Sieve\Acquisitions\US2\US2_20_40_woC_woS.csv", [2, Inf]);
Ts = US2_20_40.TIME(2) - US2_20_40.TIME(1);

%Elimination of last nan data
US2_20_40 = US2_20_40(1:end-1,:);

%Creation of Vpiezo and Ipiezo channels
US2_20_40.Vpiezo = US2_20_40.Vgen - US2_20_40.Vres;
US2_20_40.Ipiezo = US2_20_40.Vres ./ 50;

%Number of expected singularities
np = 3;
nz = 2;

opt = tfestOptions('Display','on');

%Loading of the data
US2_20_40_data = iddata(US2_20_40.Vpiezo, US2_20_40.Ipiezo, Ts);
US2_20_40_tf = tfest(US2_20_40_data,np, nz, opt);
US2_20_40_tf = idtf(US2_20_40_tf.num,US2_20_40_tf.den);

US2_20_40_tf

% Poles and Zeros
P = pole(US2_20_40_tf);
Z = zero(US2_20_40_tf);

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


%% Bode plot
figure
bode(US2_20_40_tf);
figure
bode(US2_tf);

X = [1e4:0.01:1e6];
Y = freqresp(US2_20_40_tf, X);
module = abs(squeeze(Y(1,1,:)));
phase = angle(squeeze(Y(1,1,:)));
figure() 
semilogx(X,module')
subplot(2,1,2)
semilogx(Y,phase')

%% Message dialog box Cp R L C
msg1 = "Cp = "  + num2str(Cp)   + " F";
msg2 = "R = "   + num2str(R)    + " Ohm";
msg3 = "L = "   + num2str(L)    + " H";
msg4 = "C = "   + num2str(C)    + " C";
showmsgbox1 = msgbox({msg1 msg2 msg3 msg4},'Results');
th1 = findall(showmsgbox1, 'Type', 'Text');                   %get handle to text within msgbox
th1.FontSize = 10;        

%% Message dialog box wz wp 
msg5 = "poles:   fn = "  + num2str(round(fn_p))   + " Hz";
msg6 = "zeroes: fn = "   + num2str(round(fn_z))   + " Hz";
showmsgbox2 = msgbox({msg5, msg6},'Results');
th2 = findall(showmsgbox2, 'Type', 'Text');                   %get handle to text within msgbox
th2.FontSize = 10;  