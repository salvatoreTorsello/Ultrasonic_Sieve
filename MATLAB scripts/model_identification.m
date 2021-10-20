clc; clear;

%% Convert files
converter;

%% Load file
load('C:\git\Ultrasonic_Sieve\Acquisitions\output\Test_File_RLC_Giusto_Session.mat');

Frequency = Frequency.*(2*pi);

%% Call system identification toolbox
systemIdentification;