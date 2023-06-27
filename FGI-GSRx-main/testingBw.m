clc;
clear all;
close all;
load('BigLeo_200km_acq.mat');
%load('BigLeo2_acq_result.mat')
settings.sys.msToProcess=2000;


%FLL NoiseBandwidth Settings
settings.gale1b.fllNoiseBandwidthWide=60;

%PLL NoiseBandwidth Settings
settings.gale1b.pllNoiseBandwidthWide=60;

%DLL NoiseBandwidth Settings
settings.gale1b.dllNoiseBandwidth=10;

trackBwData = doTracking(acqData,settings);

plotTracking(trackBwData,settings);

