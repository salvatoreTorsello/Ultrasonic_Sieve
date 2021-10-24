%% Import DATA for US3 without Cable and Without Sieve %%

US3_woC.data = importData("C:\git\Ultrasonic_Sieve\Acquisitions\US3\US3_20_40_woC_woS.csv", [2, Inf]);
Ts = US3_woC.data.TIME(2) - US3_woC.data.TIME(1);

%Elimination of last nan data
US3_woC.data = US3_woC.data(1:end-1,:);

%Creation of Vpiezo and Ipiezo channels
US3_woC.data.Vpiezo = US3_woC.data.Vgen - US3_woC.data.Vres;
US3_woC.data.Ipiezo = US3_woC.data.Vres ./ 50;

%Number of expected singularities
np = 3;
nz = 2;

opt = tfestOptions('Display','on');

%Loading of the data
US3_woC.dataObj = iddata(US3_woC.data.Vpiezo, US3_woC.data.Ipiezo, Ts);
US3_woC.tf = tfest(US3_woC.dataObj,np, nz, opt);
US3_woC.tf = idtf(US3_woC.tf.num,US3_woC.tf.den);

US3_woC.tf

%% Singularities calculations

% Poles and Zeros
US3_woC.P = pole(US3_woC.tf);
US3_woC.Z = zero(US3_woC.tf);

%poles calculations
alpha_p = abs(real(US3_woC.P(2)));
wd_p = abs(imag(US3_woC.P(2)));

syms zeta_p
eqn = zeta_p/alpha_p == sqrt(1-(zeta_p)^2)/wd_p;
S1 = solve(eqn, zeta_p);
US3_woC.zeta_p = double(S1);

syms wn_p
eqn = wn_p == wd_p/sqrt(1-(US3_woC.zeta_p)^2);
S2 = solve(eqn, wn_p);
US3_woC.wn_p = double(S2);
US3_woC.fn_p = US3_woC.wn_p/(2*pi);

syms Q_p 
eqn = Q_p == 1 / (2 * US3_woC.zeta_p);
S = solve(eqn, Q_p);
US3_woC.Q_p = double(S);

%zeroes calculations
alpha_z = abs(real(US3_woC.Z(2)));
wd_z = abs(imag(US3_woC.Z(2)));

syms zeta_z
eqn = zeta_z/alpha_z == sqrt(1-(zeta_z)^2)/wd_z;
S1 = solve(eqn, zeta_z);
US3_woC.zeta_z = double(S1);

syms wn_z
eqn = wn_z == wd_z/sqrt(1-(US3_woC.zeta_z)^2);
S2 = solve(eqn, wn_z);
US3_woC.wn_z = double(S2);
US3_woC.fn_z = US3_woC.wn_z/(2*pi);

syms Q_z 
eqn = Q_z == 1 / (2 * US3_woC.zeta_p);
S = solve(eqn, Q_z);
US3_woC.Q_z = double(S);

%% Cp Computation

start = 4e3; stop = 1e6;
US3_woC.X = [start:0.1:stop];
US3_woC.Y = freqresp(US3_woC.tf, US3_woC.X, 'Hz');
US3_woC.module = abs(squeeze(US3_woC.Y(1,1,:))); US3_woC.module = US3_woC.module';
US3_woC.phase = angle(squeeze(US3_woC.Y(1,1,:))); US3_woC.phase = US3_woC.phase';

US3_woC.f_Cp = (20e3 - start)*10;
US3_woC.Z_f_Cp = abs(US3_woC.Y(US3_woC.f_Cp));
US3_woC.Cp_comp = 1/(2*pi*20e3*US3_woC.Z_f_Cp);

%% Parameters Calculations R L C
US3_woC.Cp = US3_woC.Cp_comp;

syms L C
eqn1 = US3_woC.wn_p^2 == (C + US3_woC.Cp)/(L * C * US3_woC.Cp);
eqn2 = US3_woC.wn_z^2 == 1 / (L * C);
S = solve([eqn1, eqn2], [L, C]);
US3_woC.L = double(S.L);
US3_woC.C = double(S.C);

syms R
eqn = R / US3_woC.L == 2* US3_woC.zeta_p* US3_woC.wn_p;
S = solve(eqn, R);
US3_woC.R = double(S);


%% Plots

start = 4e3; stop = 1e6;
US3_woC.X = [start:0.1:stop];
US3_woC.Y = freqresp(US3_woC.tf, US3_woC.X, 'Hz');
US3_woC.module = abs(squeeze(US3_woC.Y(1,1,:))); US3_woC.module = US3_woC.module';
US3_woC.phase = angle(squeeze(US3_woC.Y(1,1,:))); US3_woC.phase = US3_woC.phase';
    
figure('NumberTitle', 'off', 'Name', 'US3 without cable');
subplot(2,1,1)
semilogx(US3_woC.X,US3_woC.module)
xlabel('Frequency [Hz]');
ylabel('Magnitude [Ohm]');
hold on;grid on;

x = [US3_woC.X(round(US3_woC.fn_p-start)*10)        US3_woC.X(round(US3_woC.fn_z-start)*10)];
y = [US3_woC.module(round(US3_woC.fn_p-start)*10)   US3_woC.module(round(US3_woC.fn_z-start)*10)];
labels = {"@fn_p"+num2str(round(y(1)))+"  ","@fn_z"+num2str(round(y(2)))+"  "};
plot(x,y,'o')
text(x,y,labels,'VerticalAlignment','middle','HorizontalAlignment','right')

subplot(2,1,2)
semilogx(US3_woC.X,US3_woC.phase)
xlabel('Frequency [Hz]');
ylabel('Phase [deg]');

hold on;grid on;
sgtitle("Piezo US3 Impedance Transfer Function without cable (fn_p = "+num2str(round(US3_woC.fn_p))+" Hz ; fn_z = "+num2str(round(US3_woC.fn_z))+" Hz)");

%% Message dialog box Cp R L C wz wp 
msg  = "US3 without cable";
emptyline = "";
msg1 = "Cp = "  + num2str(US3_woC.Cp)   + " F";
msg2 = "R = "   + num2str(US3_woC.R)    + " Ohm";
msg3 = "L = "   + num2str(US3_woC.L)    + " H";
msg4 = "C = "   + num2str(US3_woC.C)    + " C";
msg5 = "poles:   fn = "  + num2str(round(US3_woC.fn_p))   + " Hz";
msg6 = "zeroes: fn = "   + num2str(round(US3_woC.fn_z))   + " Hz";
showmsgbox1 = msgbox({msg emptyline msg1 msg2 msg3 msg4 emptyline msg5 msg6},'US3');
th1 = findall(showmsgbox1, 'Type', 'Text');                   %get handle to text within msgbox
th1.FontSize = 10;  

%% Clear worlspace
clear US3_tf P G US3_data np nz US3 opt Ts msg emptyline msg1 msg2 msg3 msg4 th1 showmsgbox1 msg5 msg6 th2 showmsgbox2 start stop 
clear alpha_p alpha_z and C eqn eqn1 eqn2 L labels Q_p Q_z R S S1 S2 S3 US3_woC.dataObj wd_p wd_z wn_p wn_z x y zeta_p zeta_z