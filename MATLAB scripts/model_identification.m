%clc; clear;

%% Convert files
%converter;


%% Load file
%%load('C:\git\Ultrasonic_Sieve\Acquisitions\output\Test_File_RLC_Giusto_Session.mat');
%load('C:\git\Ultrasonic_Sieve\Acquisitions\output\2021_10_21 US3 with cable\tek0004_Session.mat');

%Frequency = Frequency.*(2*pi);

US3_0_10_woC_woS = US3_0_10_woC_woS(1:end-1,:);
US3_0_10_woC_woS.Vpiezo = US3_0_10_woC_woS.Vgen - US3_0_10_woC_woS.Vres;
US3_0_10_woC_woS.Ipiezo = US3_0_10_woC_woS.Vres ./ 50;

US3_20_40_woC_woS = US3_20_40_woC_woS(1:end-1,:);
US3_20_40_woC_woS.Vpiezo = US3_20_40_woC_woS.Vgen - US3_20_40_woC_woS.Vres;
US3_20_40_woC_woS.Ipiezo = US3_20_40_woC_woS.Vres ./ 50;

%% Call system identification toolbox
systemIdentification;


%% plot
figure
plot(US3_0_10_woC_woS.TIME, US3_0_10_woC_woS.Vres);
figure
plot(US3_0_10_woC_woS.TIME, US3_0_10_woC_woS.Vgen);


figure
plot(US3_20_40_woC_woS.TIME, US3_20_40_woC_woS.Vres);
figure
plot(US3_20_40_woC_woS.TIME, US3_20_40_woC_woS.Vgen);