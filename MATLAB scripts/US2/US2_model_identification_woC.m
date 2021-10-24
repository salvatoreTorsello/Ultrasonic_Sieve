%% Import DATA for US2 without Cable and Without Sieve %%

US2_woC.data = importData("C:\git\Ultrasonic_Sieve\Acquisitions\US2\US2_20_40_woC_woS.csv", [2, Inf]);
Ts = US2_woC.data.TIME(2) - US2_woC.data.TIME(1);

%Elimination of last nan data
US2_woC.data = US2_woC.data(1:end-1,:);

%Creation of Vpiezo and Ipiezo channels
US2_woC.data.Vpiezo = US2_woC.data.Vgen - US2_woC.data.Vres;
US2_woC.data.Ipiezo = US2_woC.data.Vres ./ 50;

%Number of expected singularities
np = 3;
nz = 2;

opt = tfestOptions('Display','on');

%Loading of the data
US2_woC.dataObj = iddata(US2_woC.data.Vpiezo, US2_woC.data.Ipiezo, Ts);
US2_woC.tf = tfest(US2_woC.dataObj,np, nz, opt);
US2_woC.tf = idtf(US2_woC.tf.num,US2_woC.tf.den);

US2_woC.tf

%% Singularities calculations

% Poles and Zeros
US2_woC.P = pole(US2_woC.tf);
US2_woC.Z = zero(US2_woC.tf);

%poles calculations
alpha_p = abs(real(US2_woC.P(2)));
wd_p = abs(imag(US2_woC.P(2)));

syms zeta_p
eqn = zeta_p/alpha_p == sqrt(1-(zeta_p)^2)/wd_p;
S1 = solve(eqn, zeta_p);
US2_woC.zeta_p = double(S1);

syms wn_p
eqn = wn_p == wd_p/sqrt(1-(US2_woC.zeta_p)^2);
S2 = solve(eqn, wn_p);
US2_woC.wn_p = double(S2);
US2_woC.fn_p = US2_woC.wn_p/(2*pi);

syms Q_p 
eqn = Q_p == 1 / (2 * US2_woC.zeta_p);
S = solve(eqn, Q_p);
US2_woC.Q_p = double(S);

%zeroes calculations
alpha_z = abs(real(US2_woC.Z(2)));
wd_z = abs(imag(US2_woC.Z(2)));

syms zeta_z
eqn = zeta_z/alpha_z == sqrt(1-(zeta_z)^2)/wd_z;
S1 = solve(eqn, zeta_z);
US2_woC.zeta_z = double(S1);

syms wn_z
eqn = wn_z == wd_z/sqrt(1-(US2_woC.zeta_z)^2);
S2 = solve(eqn, wn_z);
US2_woC.wn_z = double(S2);
US2_woC.fn_z = US2_woC.wn_z/(2*pi);

syms Q_z 
eqn = Q_z == 1 / (2 * US2_woC.zeta_p);
S = solve(eqn, Q_z);
US2_woC.Q_z = double(S);

%% Cp Computation

start = 4e3; stop = 1e6;
US2_woC.X = [start:0.1:stop];
US2_woC.Y = freqresp(US2_woC.tf, US2_woC.X, 'Hz');
US2_woC.module = abs(squeeze(US2_woC.Y(1,1,:))); US2_woC.module = US2_woC.module';
US2_woC.phase = angle(squeeze(US2_woC.Y(1,1,:))); US2_woC.phase = US2_woC.phase';

US2_woC.f_Cp = (20e3 - start)*10;
US2_woC.Z_f_Cp = abs(US2_woC.Y(US2_woC.f_Cp));
US2_woC.Cp_comp = 1/(2*pi*20e3*US2_woC.Z_f_Cp);

%% Parameters Calculations R L C
US2_woC.Cp = US2_woC.Cp_comp;

syms L C
eqn1 = US2_woC.wn_p^2 == (C + US2_woC.Cp)/(L * C * US2_woC.Cp);
eqn2 = US2_woC.wn_z^2 == 1 / (L * C);
S = solve([eqn1, eqn2], [L, C]);
US2_woC.L = double(S.L);
US2_woC.C = double(S.C);

syms R
eqn = R / US2_woC.L == 2* US2_woC.zeta_p* US2_woC.wn_p;
S = solve(eqn, R);
US2_woC.R = double(S);


%% Plots

start = 4e3; stop = 1e6;
US2_woC.X = [start:0.1:stop];
US2_woC.Y = freqresp(US2_woC.tf, US2_woC.X, 'Hz');
US2_woC.module = abs(squeeze(US2_woC.Y(1,1,:))); US2_woC.module = US2_woC.module';
US2_woC.phase = angle(squeeze(US2_woC.Y(1,1,:))); US2_woC.phase = US2_woC.phase';
    
figure('NumberTitle', 'off', 'Name', 'US2 without cable');
subplot(2,1,1)
semilogx(US2_woC.X,US2_woC.module)
xlabel('Frequency [Hz]');
ylabel('Magnitude [Ohm]');
hold on;grid on;

x = [US2_woC.X(round(US2_woC.fn_p-start)*10)        US2_woC.X(round(US2_woC.fn_z-start)*10)];
y = [US2_woC.module(round(US2_woC.fn_p-start)*10)   US2_woC.module(round(US2_woC.fn_z-start)*10)];
labels = {"@fn_p"+num2str(round(y(1)))+"  ","@fn_z"+num2str(round(y(2)))+"  "};
plot(x,y,'o')
text(x,y,labels,'VerticalAlignment','middle','HorizontalAlignment','right')

subplot(2,1,2)
semilogx(US2_woC.X,US2_woC.phase)
xlabel('Frequency [Hz]');
ylabel('Phase [deg]');

hold on;grid on;
sgtitle("Piezo US2 Impedance Transfer Function without cable (fn_p = "+num2str(round(US2_woC.fn_p))+" Hz ; fn_z = "+num2str(round(US2_woC.fn_z))+" Hz)");

%% Message dialog box Cp R L C wz wp 
msg  = "US2 without cable";
emptyline = "";
msg1 = "Cp = "  + num2str(US2_woC.Cp)   + " F";
msg2 = "R = "   + num2str(US2_woC.R)    + " Ohm";
msg3 = "L = "   + num2str(US2_woC.L)    + " H";
msg4 = "C = "   + num2str(US2_woC.C)    + " C";
msg5 = "poles:   fn = "  + num2str(round(US2_woC.fn_p))   + " Hz";
msg6 = "zeroes: fn = "   + num2str(round(US2_woC.fn_z))   + " Hz";
showmsgbox1 = msgbox({msg emptyline msg1 msg2 msg3 msg4 emptyline msg5 msg6},'US2');
th1 = findall(showmsgbox1, 'Type', 'Text');                   %get handle to text within msgbox
th1.FontSize = 10;  

%% Clear worlspace
clear US2_tf P G US2_data np nz US2 opt Ts msg emptyline msg1 msg2 msg3 msg4 th1 showmsgbox1 msg5 msg6 th2 showmsgbox2 start stop 
clear alpha_p alpha_z and C eqn eqn1 eqn2 L labels Q_p Q_z R S S1 S2 S3 US2_woC.dataObj wd_p wd_z wn_p wn_z x y zeta_p zeta_z