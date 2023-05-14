clc;
clear all;
load('PRN01.txt');
load('PRN02.txt');
load('PRN03.txt');
load('PRN04.txt');
load('PRN05.txt');
load('PRN07.txt');
load('PRN08.txt');
load('PRN09.txt');
load('PRN11.txt');
load('PRN12.txt');

BigLeo=1;

if(BigLeo==1)
    file1="BigLEO_default_track_result.mat";
    file2="BigLEO_advanced_track_result.mat";
    row=3;
    column=4;
    num_sats=10;
else
    file1="LEO_default_track_result.mat";
    file2="LEO_advanced_track_result.mat";
    row=2;
    column=3;
    num_sats=6;
end

load(file1);

channels = -[PRN01 PRN02 PRN03 PRN04 PRN05 PRN07 PRN08 PRN09 PRN11 PRN12];

channels = channels(1:496,:);

labels =["PRN01" "PRN02" "PRN03" "PRN04" "PRN05" "PRN07" "PRN08" "PRN09" "PRN11" "PRN12"];

tiledlayout(row,column)
for i=1:num_sats
    
    axis = 500:100:50000;
    
    %     figure;
    nexttile;
    plot(axis, channels(:,i), '.');
    hold on;
    
    axis = 1:4:50000;
    PRNfgi=trackData.gale1b.channel(i).doppler.';
    PRNfgi = PRNfgi(4:4:end, :);

    plot(axis, PRNfgi, '.');
    hold off;

    legend(["Doppler Skydel" "Doppler FGI Default"]);
    title(labels(i)+ " Default");
    
end

load(file2);

figure;
tiledlayout(row,column)
for i=1:num_sats

    axis = 500:100:50000;

    %     figure;
    nexttile;
    plot(axis, channels(:,i), '.');
    hold on;

    axis = 1:4:50000;
    PRNfgi=trackData.gale1b.channel(i).doppler.';
    PRNfgi = PRNfgi(4:4:end, :);

    plot(axis, PRNfgi, '.');
    hold off;

    legend(["Doppler Skydel" "Doppler FGI Advanced"]);
    title(labels(i) + " Advanced");
    
end

for ii=1:num_sats

    offset_code = cumsum(trackData.gale1b.channel(ii).blockSize - settings.gale1b.samplesPerCode)*settings.gale1b.codeFreqBasis/settings.gale1b.samplingFreq;

    accum_codePhase = (offset_code - trackData.gale1b.channel(ii).codePhase)* 299792458/settings.gale1b.codeFreqBasis;

end

figure;

plot(accum_codePhase./256);
hold on;

plot(offset_code);
legend(["Accumulative Code Phase" "Code Offset"]);
hold off;
