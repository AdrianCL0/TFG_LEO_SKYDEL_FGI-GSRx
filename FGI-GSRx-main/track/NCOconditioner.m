%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%FF LEO-PNT-UE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tR = NCOconditioner(tR,ch)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Copy updated local variables
trackChannelData = tR.channel(ch);
loopCnt = trackChannelData.loopCnt;
carrFreqBasis = trackChannelData.acquiredFreq;
codeFreqBasis = tR.codeFreqBasis;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CARRIER
totalCarrError = trackChannelData.phaseDiscrFilt(loopCnt);
trackChannelData.carrError(loopCnt) = totalCarrError;

% Calculate NCO feedback
carrNco = totalCarrError;

% Calculate carrier frequency
carrFreq = carrFreqBasis + totalCarrError;
trackChannelData.carrFreq(loopCnt) = carrFreq;

% Store values for next round -> USED IN OTHER PLACES
trackChannelData.prevCarrFreq = carrNco;
trackChannelData.prevCarrError = totalCarrError;

% Calculate doppler frequency
trackChannelData.doppler(loopCnt) = carrFreq - trackChannelData.intermediateFreq; %doppler = (IF frequency estimate during current loop of PLL) - (base IF freq)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CODE
% Calculate code error from discriminator function
codeError = trackChannelData.codeDiscrFilt(loopCnt);
trackChannelData.codeError = codeError;   

% Calculate NCO feedback
codeNco = codeError;

trackChannelData.codeNco(loopCnt) = codeNco;            

% Calculate code frequency
codeFreq = codeFreqBasis - codeNco + ( -carrFreq - trackChannelData.intermediateFreq )/trackChannelData.carrToCodeRatio;
trackChannelData.codeFreq(loopCnt) = codeFreq;
trackChannelData.prevCodeFreq = codeFreq;

% Store values for next round -> NOT NEEDED
trackChannelData.prevCodeNco = codeNco;
trackChannelData.prevCodeError = codeError;   



% Copy updated local variables
tR.channel(ch) = trackChannelData;

