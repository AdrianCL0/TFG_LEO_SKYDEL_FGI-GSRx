%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Copyright 2015-2021 Finnish Geospatial Research Institute FGI, National
%% Land Survey of Finland. This file is part of FGI-GSRx software-defined
%% receiver. FGI-GSRx is a free software: you can redistribute it and/or
%% modify it under the terms of the GNU General Public License as published
%% by the Free Software Foundation, either version 3 of the License, or any
%% later version. FGI-GSRx software receiver is distributed in the hope
%% that it will be useful, but WITHOUT ANY WARRANTY, without even the
%% implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. 
%% See the GNU General Public License for more details. You should have
%% received a copy of the GNU General Public License along with FGI-GSRx
%% software-defined receiver. If not, please visit the following website 
%% for further information: https://www.gnu.org/licenses/
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eph, obsCh] = gale1bDecodeEphemeris(obsCh, I_P, prn, signalSettings, const)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function decodes ephemerides and time of frame start from the given bit
% stream. 
%
% Inputs:
%   obsCh               - Observations for one channel
%   I_P                 - Prompt correlator output
%   prn                 - Prn number
%   signalSettings      - Settings for one signal
%   const               - Constants
%
% Outputs:
%   eph                 - SV ephemeris
%   obsCh               - Observations for one channel
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
obsCh.bEphOk = false;
eph = [];

signal = 'gale1b';

% Pi used in the Galileo coordinate system
galileoPi = const.PI;

% Extract nav bits from track channel data 
navBitsSamples = I_P(4 * obsCh.firstSubFrame : 4 : 4 * (obsCh.firstSubFrame + 250*2*20 -1))';

% Now threshold the output and convert it to -1 and +1 
navBits( navBitsSamples > 0)  =  1;
navBits( navBitsSamples <= 0) = -1;

% Calculate cross correlation between nav bits and preamble
corrValPreamble = calcCrossCorrelation(navBits,signalSettings.preamble);

% Find peaks in CC values
indPositiveCorrelation = find(corrValPreamble>=10);
indNegativeCorrelation = find(corrValPreamble<=-10);

if length(indPositiveCorrelation) > length(indNegativeCorrelation)
    % We have more positive than negative matches, i.e. bits are NOT
    % inverted ! Only change -1:s to 0:s.
    navBits( find(navBits==-1) ) = 0;
else
    % We have more negative than positive matches, i.e. bits are most
    % probably inverted. Flip bits and change -1:s.
    navBits( find(navBits==1) ) = 0;
    navBits( find(navBits==-1) ) = 1;        
end

% Decode from symbols to the navigation bits (250 symbols -> 120 bits)
[decodedNavBits] = gale1bDecoderDeinterleaver(navBits,signal);

% Convert from decimal to binary 
% The function ephemeris expects input in binary form. In Matlab it is
% a string array containing only "0" and "1" characters.
bits = dec2bin(decodedNavBits');

% Check if the parameters are strings 
if ~ischar(bits)
    error('The parameter BITS must be a character array!');
end

% if the page starts with even/odd == 0, then ignore the first 120 bits of
% the page: it will then always start with even/odd = 1, which is needed to
% arrange the bits into word

evenOddTypeBeginningPage = bin2dec(bits(1));
pageTypeBeginningPage = bin2dec(bits(2));
if evenOddTypeBeginningPage == 1 && pageTypeBeginningPage == 0
    bits = bits(121:end);
    shifttow = 0;
else
    shifttow = 1;
end

foundPages = 0;

for i=1:(length(bits)/240)
    bitsArrangedPageWise = bits((i-1)*240+1: i*240);
    
    % CRC check of bits
    chk(i) = gale1bCrcCheck(bitsArrangedPageWise);
       
    % TBA: Wait to implement this since we need tow for the
    if(chk ~= 0) 
        fprintf('CRC check fails!');
        obsCh.bEphOk = false;
        break;
    end
    
    % Arrange bits
    evenOddType = bin2dec(bitsArrangedPageWise(1));
    pageType(i) = bin2dec(bitsArrangedPageWise(2));
    if evenOddType == 0 && pageType(i) == 0 % type odd
        %Arrange the bits into a Word of length 128 bits (112 + 16)        
        bitsArrangedWordWise(1:112) = bitsArrangedPageWise(3:3+111);
        bitsArrangedWordWise(113:128) = bitsArrangedPageWise(120+3:120+3+15);
        wordType(i,:) = bin2dec(bitsArrangedWordWise(1:6));
    else
        wordType(i,:) = 7; % This is a hack. Othervise we will get funny page numbers. To be checked. SS
    end
    
    % Decode data words
    switch wordType(i,:) 
        case 0 % Word Type 0
            time =  bin2dec(bitsArrangedWordWise(7:8));
            if time == 2
                WN_0 = bin2dec(bitsArrangedWordWise(97:108));
                TOW_0 = bin2dec(bitsArrangedWordWise(109:128));
            else
                fprintf('No valid WN & TOW');
            end
            foundPages = bitset(foundPages,1);
        case 1 % Word Type 1
            IOD_nav_1 = bin2dec(bitsArrangedWordWise(7:16));
            t0e_1 = bin2dec(bitsArrangedWordWise(17:30)) * 60;
            M0_1 = twosComp2dec(bitsArrangedWordWise(31:62)) * 2^(-31) * galileoPi;            
            e_1 = bin2dec(bitsArrangedWordWise(63:94)) * 2^(-33);
            A_1 = bin2dec(bitsArrangedWordWise(95:126)) * 2^(-19);
            foundPages = bitset(foundPages,2);
        case 2 % Word Type 2
            IOD_nav_2 = bin2dec(bitsArrangedWordWise(7:16));
            OMEGA_0_2 = twosComp2dec(bitsArrangedWordWise(17:48)) * 2^(-31) * galileoPi;
            i_0_2 = twosComp2dec(bitsArrangedWordWise(49:80)) * 2^(-31) * galileoPi;
            omega_2 = twosComp2dec(bitsArrangedWordWise(81:112)) * 2^(-31) * galileoPi;
            iDot_2 = twosComp2dec(bitsArrangedWordWise(113:126)) * 2^(-43) * galileoPi;
            foundPages = bitset(foundPages,3);
        case 3 % Word Type 3
            IOD_nav_3 = bin2dec(bitsArrangedWordWise(7:16));
            OMEGA_dot_3 = twosComp2dec(bitsArrangedWordWise(17:40)) * 2^(-43) * galileoPi;
            delta_n_3 = twosComp2dec(bitsArrangedWordWise(41:56)) * 2^(-43) * galileoPi;
            C_uc_3 = twosComp2dec(bitsArrangedWordWise(57:72)) * 2^(-29);
            C_us_3 = twosComp2dec(bitsArrangedWordWise(73:88)) * 2^(-29);
            C_rc_3 = twosComp2dec(bitsArrangedWordWise(89:104))* 2^(-5);
            C_rs_3 = twosComp2dec(bitsArrangedWordWise(105:120))* 2^(-5);
            SISA_3 = bin2dec(bitsArrangedWordWise(121:128));
            foundPages = bitset(foundPages,4);
        case 4 % Word Type 4
            IOD_nav_4 = bin2dec(bitsArrangedWordWise(7:16));
            SV_ID_4 = bin2dec(bitsArrangedWordWise(17:22));
            C_ic_4 = twosComp2dec(bitsArrangedWordWise(23:38))*2^(-29);
            C_is_4 = twosComp2dec(bitsArrangedWordWise(39:54))*2^(-29);
            t0c_4 = bin2dec(bitsArrangedWordWise(55:68)) * 60;
            af0_4 = twosComp2dec(bitsArrangedWordWise(69:99)) * 2^(-34);
            af1_4 = twosComp2dec(bitsArrangedWordWise(100:120)) * 2^(-46);
            af2_4 = twosComp2dec(bitsArrangedWordWise(121:126)) * 2^(-59);
            foundPages = bitset(foundPages,5);
        case 5 % Word Type 5
            % TBA Require revision from ICD
            ai0_5 = bin2dec(bitsArrangedWordWise(7:17))* 2^(-2);
            ai1_5 = twosComp2dec(bitsArrangedWordWise(18:28))* 2^(-8);
            ai2_5 = twosComp2dec(bitsArrangedWordWise(29:42))* 2^(-15);
            Region1_flag_5 = bin2dec(bitsArrangedWordWise(43));
            Region2_flag_5 = bin2dec(bitsArrangedWordWise(44));
            Region3_flag_5 = bin2dec(bitsArrangedWordWise(45));
            Region4_flag_5 = bin2dec(bitsArrangedWordWise(46));
            Region5_flag_5 = bin2dec(bitsArrangedWordWise(47));
            BGD_E1E5a_5 = twosComp2dec(bitsArrangedWordWise(48:57)) * 2^(-32);
            BGD_E1E5b_5 = twosComp2dec(bitsArrangedWordWise(58:67)) * 2^(-32);
            E5b_HS_5 = bin2dec(bitsArrangedWordWise(68:69));
            E1B_HS_5 = bin2dec(bitsArrangedWordWise(70:71));
            E5b_DVS_5 = bin2dec(bitsArrangedWordWise(72));
            E1B_DVS_5 = bin2dec(bitsArrangedWordWise(73));
            WN_5 = bin2dec(bitsArrangedWordWise(74:85));
            TOW_5 = bin2dec(bitsArrangedWordWise(86:105));
            ind_TOW_5 = i;
            foundPages = bitset(foundPages,6);
        case 6 % Word Type 6: GST-UTC conversion parameters
            % Require revision from ICD
            A0_6 = bin2dec(bitsArrangedWordWise(7:38));
            A1_6 = bin2dec(bitsArrangedWordWise(39:62));
            Delta_tLS_6 = bin2dec(bitsArrangedWordWise(63:70));
            t_ot_6 = bin2dec(bitsArrangedWordWise(71:78)); 
            WN_ot_6 = bin2dec(bitsArrangedWordWise(79:86));
            WN_LSF_6 = bin2dec(bitsArrangedWordWise(87:94));
            DN_6 = bin2dec(bitsArrangedWordWise(95:97));
            Delta_tLSF_6 = bin2dec(bitsArrangedWordWise(98:105));
            TOW_6 = bin2dec(bitsArrangedWordWise(106:125));
            foundPages = bitset(foundPages,7);            
        case 7
            ;
        case 8
            ;
        case 9
            ;
        case 10
            % GPS-Galileo time comversion parameters
            A_0G = bin2dec(bitsArrangedWordWise(87:102)) * 2^(-35);            
            A_1G = bin2dec(bitsArrangedWordWise(103:114)) * 2^(-51);            
            t_0G = bin2dec(bitsArrangedWordWise(115:122)) * 3600;            
            WN_0G = bin2dec(bitsArrangedWordWise(123:128));            
            foundPages = bitset(foundPages,11);            
        case 63 % Dummy data word: Type 63
            ;
        otherwise
            fprintf('Wrong Word Number! Word type: %d. Check CRC!\n',wordType(i));
    end     
end

obsCh.bEphOk = false;
eph = [];
    
% Let's also decode into same format as for GPS.
if(bitand(foundPages,63) == 63)
    % Word type 0
    eph.weekNumber = WN_0;

    % Word type 1
    eph.IODC = IOD_nav_1;
    eph.IODE_sf2 = IOD_nav_1;
    eph.M_0 = M0_1;
    eph.e = e_1;
    eph.sqrtA = A_1;
    eph.t_oe = t0e_1;
    eph.IODE_sf3 = IOD_nav_1;

    % Word type 2
    eph.omega_0 = OMEGA_0_2;
    eph.i_0 = i_0_2;
    eph.omega = omega_2;
    eph.iDot = iDot_2;

    % Word type 3
    eph.C_rs = C_rs_3;
    eph.deltan = delta_n_3;
    eph.C_uc = C_uc_3;
    eph.C_us = C_us_3;
    eph.C_rc = C_rc_3;
    eph.omegaDot = OMEGA_dot_3;
    eph.SISA = SISA_3;

    % Word type 4
    eph.t_oc = t0c_4;
    eph.a_f2 = af2_4;
    eph.a_f1 = af1_4;
    eph.a_f0 = af0_4;
    eph.C_ic = C_ic_4;
    eph.C_is = C_is_4;

    % Word type 5
    eph.ai0_5 = ai0_5;
    eph.ai1_5 = ai1_5;
    eph.ai2_5 = ai2_5;
    eph.Region1_flag_5 = Region1_flag_5;
    eph.Region2_flag_5 = Region2_flag_5;
    eph.Region3_flag_5 = Region3_flag_5;
    eph.Region4_flag_5 = Region4_flag_5;
    eph.Region5_flag_5 = Region5_flag_5;    
    eph.T_GD = BGD_E1E5b_5;
    eph.geo = false;
    eph.E1B_DVS = E1B_DVS_5;
    eph.E1B_HS = E1B_HS_5;
    % TOW_5 is from the last decoded wordtype = 5.
    % The index tells us in which word this was.
    % Each word corresponds to 2 seconds in TOW.
    % If, for example we decoded TOW_5 in word 16 that TOW points to the
    % beginning of that WORD and we need to subtract 15 x 2 sec to get the TOW
    % at the beginning of the bitbuffer.
    % Also we need to subtract one sec since our data starts with odd page and
    % frames starts with even page
    TOW = TOW_5 - (2*(ind_TOW_5-1)) - 1 +  shifttow;
    
    obsCh.bEphOk = true;
    obsCh.tow = TOW;    
end

if(bitand(foundPages,64) == 64)
    % GST-UTC conversion parameters
    eph.A0 = A0_6;
    eph.A1 = A1_6;
    eph.Delta_tLS = Delta_tLS_6;
    eph.t_ot = t_ot_6; 
    eph.WN_ot = WN_ot_6;
    eph.WN_LSF = WN_LSF_6;
    eph.D = DN_6;
    eph.Delta_tLSF = Delta_tLSF_6;
    eph.TOW_6 = TOW_6;    
end

if(bitand(foundPages,1024) == 1024)
    % Word type 10
    % GPS to Galileo time conversion parameters
    eph.A_0G = A_0G;
    eph.A_1G = A_1G;
    eph.t_0G = t_0G;
    eph.WN_0G = WN_0G;
end

% Print status
if(obsCh.bEphOk == true)
    disp(['   Ephemeris for ', obsCh.signal ,' prn ', ...
        int2str(prn),' found.'])          
else
    disp(['   Ephemeris for ', obsCh.signal ,' prn ', ...
        int2str(prn),' is NOT found.'])  
    
    % Word type 0
    eph.weekNumber = 0;

    % Word type 1
    eph.IODC = 0;
    eph.IODE_sf2 = 0;
    eph.M_0 = 0;
    eph.e = 0;
    eph.sqrtA = 0;
    eph.t_oe = 0;
    eph.IODE_sf3 = 0;

    % Word type 2
    eph.omega_0 = 0;
    eph.i_0 = 0;
    eph.omega = 0;
    eph.iDot = 0;

    % Word type 3
    eph.C_rs = 0;
    eph.deltan = 0;
    eph.C_uc = 0;
    eph.C_us = 0;
    eph.C_rc = 0;
    eph.omegaDot = 0;
    eph.SISA = 0;

    % Word type 4
    eph.t_oc = 0;
    eph.a_f2 = 0;
    eph.a_f1 = 0;
    eph.a_f0 = 0;
    eph.C_ic = 0;
    eph.C_is = 0;

    % Word type 5
    eph.ai0_5 = 0;
    eph.ai1_5 = 0;
    eph.ai2_5 = 0;
    eph.Region1_flag_5 = 0;
    eph.Region2_flag_5 = 0;
    eph.Region3_flag_5 = 0;
    eph.Region4_flag_5 = 0;
    eph.Region5_flag_5 = 0;    
    eph.T_GD = 0;
    eph.geo = false;
    eph.E1B_DVS = 0;
    eph.E1B_HS = 0;
    
    % GST-UTC conversion parameters
    eph.A0 = 0;
    eph.A1 = 0;
    eph.Delta_tLS = 0;
    eph.t_ot = 0; 
    eph.WN_ot = 0;
    eph.WN_LSF = 0;
    eph.D = 0;
    eph.Delta_tLSF = 0;
    eph.TOW_6 = 0;   
    
    eph.A_0G = 0;
    eph.A_1G = 0;
    eph.t_0G = 0;
    eph.WN_0G = 0;
    obsCh.bEphOk = false;    
end












	
	




