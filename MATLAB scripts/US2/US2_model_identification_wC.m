%% Import DATA for US2 without Cable and Without Sieve %%

US2_wC.data = importData("C:\git\Ultrasonic_Sieve\Acquisitions\US2\US2_20_40_wC_woS.csv", [2, Inf]);
Ts = US2_wC.data.TIME(2) - US2_wC.data.TIME(1);

%Elimination of last nan data
US2_wC.data = US2_wC.data(1:end-1,:);

%Creation of Vpiezo and Ipiezo channels
US2_wC.data.Vpiezo = US2_wC.data.Vgen - US2_wC.data.Vres;
US2_wC.data.Ipiezo = US2_wC.data.Vres ./ 50;

%Number of expected singularities
np = 3;
nz = 2;

opt = tfestOptions('Display','on');

%Loading of the data
US2_wC.dataObj = iddata(US2_wC.data.Vpiezo, US2_wC.data.Ipiezo, Ts);
US2_wC.tf = tfest(US2_wC.dataObj,np, nz, opt);
US2_wC.tf = idtf(US2_wC.tf.num,US2_wC.tf.den);

US2_wC.tf

%% Singularities calculations

% Poles and Zeros
US2_wC.P = pole(US2_wC.tf);
US2_wC.Z = zero(US2_wC.tf);

%poles calculations
alpha_p = abs(real(US2_wC.P(2)));
wd_p = abs(imag(US2_wC.P(2)));

syms zeta_p
eqn = zeta_p/alpha_p == sqrt(1-(zeta_p)^2)/wd_p;
S1 = solve(eqn, zeta_p);
US2_wC.zeta_p = double(S1);

syms wn_p
eqn = wn_p == wd_p/sqrt(1-(US2_wC.zeta_p)^2);
S2 = solve(eqn, wn_p);
US2_wC.wn_p = double(S2);
US2_wC.fn_p = US2_wC.wn_p/(2*pi);

syms Q_p 
eqn = Q_p == 1 / (2 * US2_wC.zeta_p);
S = solve(eqn, Q_p);
US2_wC.Q_p = double(S);

%zeroes calculations
alpha_z = abs(real(US2_wC.Z(2)));
wd_z = abs(imag(US2_wC.Z(2)));

syms zeta_z
eqn = zeta_z/alpha_z == sqrt(1-(zeta_z)^2)/wd_z;
S1 = solve(eqn, zeta_z);
US2_wC.zeta_z = double(S1);

syms wn_z
eqn = wn_z == wd_z/sqrt(1-(US2_wC.zeta_z)^2);
S2 = solve(eqn, wn_z);
US2_wC.wn_z = double(S2);
US2_wC.fn_z = US2_wC.wn_z/(2*pi);

syms Q_z 
eqn = Q_z == 1 / (2 * US2_wC.zeta_p);
S = solve(eqn, Q_z);
US2_wC.Q_z = double(S);

%% Cp Computation

start = 4e3; stop = 1e6;
US2_wC.X = [start:0.1:stop];
US2_wC.Y = freqresp(US2_wC.tf, US2_wC.X, 'Hz');
US2_wC.module = abs(squeeze(US2_wC.Y(1,1,:))); US2_wC.module = US2_wC.module';
US2_wC.phase = angle(squeeze(US2_wC.Y(1,1,:))); US2_wC.phase = US2_wC.phase';

US2_wC.f_Cp = (20e3 - start)*10;
US2_wC.Z_f_Cp = abs(US2_wC.Y(US2_wC.f_Cp));
US2_wC.Cp_comp = 1/(2*pi*20e3*US2_wC.Z_f_Cp);

%% Parameters Calculations R L C
US2_wC.Cp = US2_wC.Cp_comp;

syms L C
eqn1 = US2_wC.wn_p^2 == (C + US2_wC.Cp)/(L * C * US2_wC.Cp);
eqn2 = US2_wC.wn_z^2 == 1 / (L * C);
S = solve([eqn1, eqn2], [L, C]);
US2_wC.L = double(S.L);
US2_wC.C = double(S.C);

syms R
eqn = R / US2_wC.L == 2* US2_wC.zeta_p* US2_wC.wn_p;
S = solve(eqn, R);
US2_wC.R = double(S);


%% Plots

start = 4e3; stop = 1e6;
US2_wC.X = [start:0.1:stop];
US2_wC.Y = freqresp(US2_wC.tf, US2_wC.X, 'Hz');
US2_wC.module = abs(squeeze(US2_wC.Y(1,1,:))); US2_wC.module = US2_wC.module';
US2_wC.phase = angle(squeeze(US2_wC.Y(1,1,:))); US2_wC.phase = US2_wC.phase';
    
figure('NumberTitle', 'off', 'Name', 'US2 with cable');
subplot(2,1,1)
semilogx(US2_wC.X,US2_wC.module)
xlabel('Frequency [Hz]');
ylabel('Magnitude [Ohm]');
hold on;grid on;

x = [US2_wC.X(round(US2_wC.fn_p-start)*10)        US2_wC.X(round(US2_wC.fn_z-start)*10)];
y = [US2_wC.module(round(US2_wC.fn_p-start)*10)   US2_wC.module(round(US2_wC.fn_z-start)*10)];
labels = {"@fn_p"+num2str(round(y(1)))+"  ","@fn_z"+num2str(round(y(2)))+"  "};
plot(x,y,'o')
text(x,y,labels,'VerticalAlignment','middle','HorizontalAlignment','right')

subplot(2,1,2)
semilogx(US2_wC.X,US2_wC.phase)
xlabel('Frequency [Hz]');
ylabel('Phase [deg]');

hold on;grid on;
sgtitle("Piezo US2 Impedance Transfer Function with cable (fn_p = "+num2str(round(US2_wC.fn_p))+" Hz ; fn_z = "+num2str(round(US2_wC.fn_z))+" Hz)");

%% Message dialog box Cp R L C wz wp 
msg  = "US2 with cable";
emptyline = "";
msg1 = "Cp = "  + num2str(US2_wC.Cp)   + " F";
msg2 = "R = "   + num2str(US2_wC.R)    + " Ohm";
msg3 = "L = "   + num2str(US2_wC.L)    + " H";
msg4 = "C = "   + num2str(US2_wC.C)    + " C";
msg5 = "poles:   fn = "  + num2str(round(US2_wC.fn_p))   + " Hz";
msg6 = "zeroes: fn = "   + num2str(round(US2_wC.fn_z))   + " Hz";
showmsgbox1 = msgbox({msg emptyline msg1 msg2 msg3 msg4 emptyline msg5 msg6},'US2');
th1 = findall(showmsgbox1, 'Type', 'Text');                   %get handle to text within msgbox
th1.FontSize = 10;  

%% Clear worlspace
clear US2_tf P G US2_data np nz US2 opt Ts msg emptyline msg1 msg2 msg3 msg4 th1 showmsgbox1 msg5 msg6 th2 showmsgbox2 start stop 
clear alpha_p alpha_z and C eqn eqn1 eqn2 L labels Q_p Q_z R S S1 S2 S3 US2_wC.dataObj wd_p wd_z wn_p wn_z x y zeta_p zeta_z