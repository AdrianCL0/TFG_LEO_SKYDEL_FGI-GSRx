%FF LEO-PNT-UE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tR = codeLoopFilterO2(tR,ch)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set local variables
trackChannelData = tR.channel(ch);
loopCnt = trackChannelData.loopCnt;
PDIcode = trackChannelData.PDIcode;

% Calculate phase error from discriminator function
dllDiscr = trackChannelData.dllDiscr(loopCnt);
% Phase locked loop filter: Kaplan scheme using bilinear transform
% integrators
BWDLL = trackChannelData.dllNoiseBandwidth;

Wn = BWDLL/0.53;

tau_dd = Wn^2*dllDiscr;
tau_d = 1.414*Wn*dllDiscr;

IR1 = tau_dd*PDIcode;
IR2 = IR1 + trackChannelData.prevIR2_DLL;
IR3 = 0.5*(IR2 + trackChannelData.prevIR2_DLL);
trackChannelData.prevIR2_DLL = IR2;

tau_d = tau_d + IR3;

trackChannelData.codeDiscrFilt(loopCnt) = tau_d;

% Copy updated local variables
tR.channel(ch) = trackChannelData;


