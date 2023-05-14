clc;
clear all;

%  Standard gravitational parameter for the earth
mu = 398600.4418; 

% TLE file name 
filename = 'tle_satellites.txt';

% Read TLE data from file
fid = fopen(filename, 'r');

%Number of satellites to evaluate from file
num_sats=4000;

% Two-line element set
% 19-32	04236.56031392	Element Set Epoch (UTC)
% 3-7	25544	Satellite Catalog Number
% 9-16	51.6335	Orbit Inclination (degrees)
% 18-25	344.7760	Right Ascension of Ascending Node (degrees)
% 27-33	0007976	Eccentricity (decimal point assumed)
% 35-42	126.2523	Argument of Perigee (degrees)
% 44-51	325.9359	Mean Anomaly (degrees)
% 53-63	15.70406856	Mean Motion (revolutions/day)
% 64-68	32890	Revolution Number at Epoch 


for i=1:num_sats
    name = fgets(fid);
    name=name(1:end-1)+"";
    line1 = fgets(fid);
    line2 = fgets(fid);

    % read first line
    tline = line1;
    if ~ischar(tline), end
    epochY = str2double(tline(19:20));                          % Epoch year
    epochD = str2double(tline(21:32));                          % Epoch day
    epoch = epochY * 365.25 + epochD;                           % Epoch (day)
    
    % read second line
    tline = line2;
    if ~ischar(tline), end
    inc = str2double(tline(9:16));                                 % Orbit Inclination (degrees)
    raan = str2double(tline(18:25));                               % Right Ascension of Ascending Node (degrees)
    ecc = str2double(strcat('0.',tline(27:33)));                   % Eccentricity
    w = str2double(tline(35:42));                                  % Argument of Perigee (degrees)
    M = str2double(tline(44:51));                                  % Mean Anomaly (degrees)
    sma = sqrt(( mu/(str2double(tline(53:63))*2*pi/86400)^2 )^(1/3)*1000);    % Root Semi Major Axis
    rNo = str2double(tline(64:68));                                % Revolution Number at Epoch 
    
   

    if(sma>2634 && sma <2635)
         % Orbit elements print in console
        fprintf("Satellite Name: %s",name);
        fprintf("Epoch: %12.12f \n",epoch);
        fprintf("Semi Major Axis: %12.12f \n",sma);
        fprintf("Eccentricity: %12.12f \n",ecc);
        fprintf("Argument of Perigree: %12.12f \n",w);
        fprintf("Mean Anomaly: %12.12f \n",M);
        fprintf("Inclination: %12.12f \n",inc);
        fprintf("Right Ascension of Ascending Node: %12.12f \n",raan);
        fprintf("Revolution Number at Epoch: %12.12f \n\n",rNo);
        fileID = fopen('skydel_leo_satellites.txt','a');

        fprintf(fileID, "Satellite Name: %s\n", name);
        fprintf(fileID, "Epoch: %12.12f \n", epoch);
        fprintf(fileID, "Semi Major Axis: %12.12f \n", sma);
        fprintf(fileID, "Eccentricity: %12.12f \n", ecc);
        fprintf(fileID, "Argument of Perigree: %12.12f \n", w);
        fprintf(fileID, "Mean Anomaly: %12.12f \n", M);
        fprintf(fileID, "Inclination: %12.12f \n", inc);
        fprintf(fileID, "Right Ascension of Ascending Node: %12.12f \n", raan);
        fprintf(fileID, "Revolution Number at Epoch: %12.12f \n\n", rNo);

        fclose(fileID);
    else

    end

    %Print info into file
    


end
fclose(fid);
