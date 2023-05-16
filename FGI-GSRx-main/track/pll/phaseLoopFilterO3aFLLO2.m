%FF LEO-PNT-UE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tR = phaseLoopFilterO3aFLLO2(tR,ch)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set local variables
trackChannelData = tR.channel(ch);
loopCnt = trackChannelData.loopCnt;
PDIcarr = trackChannelData.PDIcarr;

% Calculate phase error from discriminator function
pllDiscr = trackChannelData.pllDiscr(loopCnt);
fllDiscr = trackChannelData.fllDiscr(loopCnt);
% Phase locked loop filter: Kaplan scheme using bilinear transform
% integrators
switch(trackChannelData.trackState)
    case 'STATE_PULL_IN'
        BWPLL = trackChannelData.pllNoiseBandwidthWide;
        BWFLL = trackChannelData.fllNoiseBandwidthWide;
    case 'STATE_COARSE_TRACKING'
        BWPLL = trackChannelData.pllNoiseBandwidthNarrow;
        BWFLL = trackChannelData.fllNoiseBandwidthNarrow;
    case 'STATE_FINE_TRACKING'
        BWPLL = trackChannelData.pllNoiseBandwidthVeryNarrow;
        BWFLL = trackChannelData.fllNoiseBandwidthVeryNarrow;
end

Wn = BWPLL/0.7845;

phi_ddd = Wn^3*pllDiscr;
trackChannelData.jitter(loopCnt+4)=phi_ddd;
phi_dd = 1.1*Wn^2*pllDiscr;
phi_d = 2.4*Wn*pllDiscr;

WnFLL = BWFLL/0.53;

phi_dd_FLL = WnFLL^2*fllDiscr;
phi_d_FLL = 1.414*WnFLL*fllDiscr;

IR1 = phi_ddd*PDIcarr;
IR2 = IR1 + trackChannelData.prevIR2_PLL(loopCnt) + phi_dd_FLL;
IR3 = 0.5*(IR2 + trackChannelData.prevIR2_PLL(loopCnt));
trackChannelData.prevIR2_PLL(loopCnt + 4) = IR2;

phi_dd = phi_dd + IR3;

IR4 = phi_dd*PDIcarr;
IR5 = IR4 + trackChannelData.prevIR5_PLL(loopCnt) + phi_d_FLL;
IR6 = 0.5*(IR5 + trackChannelData.prevIR5_PLL(loopCnt));
trackChannelData.prevIR5_PLL(loopCnt + 4) = IR5;

phi_d = phi_d + IR6;

trackChannelData.phaseDiscrFilt(loopCnt) = phi_d;

% Copy updated local variables
tR.channel(ch) = trackChannelData;


