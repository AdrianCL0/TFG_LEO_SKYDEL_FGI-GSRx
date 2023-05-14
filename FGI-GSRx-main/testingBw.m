clc;
clear all;
close all;
load('BigLeo2_acq_result.mat')
settings.sys.msToProcess=2000;


%FLL NoiseBandwidth Settings
settings.gale1b.fllNoiseBandwidthWide=20;

%PLL NoiseBandwidth Settings
settings.gale1b.pllNoiseBandwidthWide=20;

%DLL NoiseBandwidth Settings
settings.gale1b.dllNoiseBandwidth =5;

trackBwData = doTracking(acqData,settings);

plotTracking(trackBwData,settings);

