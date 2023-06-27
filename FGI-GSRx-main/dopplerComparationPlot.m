clc;
clear all;
close all;
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
    row=2;
    column=5;
    num_sats=10;
else
    file1="LEO_default_track_result.mat";
    file2="LEO_advanced_track_result.mat";
    row=2;
    column=3;
    num_sats=6;
end

load(file1);

DopplerSkydel = -[PRN01 PRN02 PRN03 PRN04 PRN05 PRN07 PRN08 PRN09 PRN11 PRN12];

DopplerSkydel = DopplerSkydel(1:496,:)./1000; %Hz to kHz

labels =["01" "02" "03" "04" "05" "07" "08" "09" "11" "12"];

tiledlayout(row,column)
for i=1:num_sats
    
    axis = 500/1000:100/1000:50000/1000; %ms to s
    
    %figure;
    nexttile;
    plot(axis, DopplerSkydel(:,i), '.',"Color","green");
    hold on;
    
    axis = 1/1000:4/1000:50000/1000; %ms to s
    DopplerFGI=trackData.gale1b.channel(i).doppler.';
    DopplerFGI = DopplerFGI(4:4:end, :)./1000; %Hz to kHz

    plot(axis, DopplerFGI, '.',"Color","blue");
    hold off;

    xlim([0 50]);
    xlabel("Time (s)");
    if(i==1 || i==6)
        ylabel("Doppler (kHz)");
    end
    title("PRN"+labels(i)+ " Default");
    
end

load(file2);

figure;
tiledlayout(row,column)
for i=1:num_sats

    axis = 500/1000:100/1000:50000/1000; %ms to s

    %     figure;
    nexttile;
    plot(axis, DopplerSkydel(:,i), '.',"Color","green");
    hold on;

    axis = 1/1000:4/1000:50000/1000; %ms to s
    DopplerFGI=trackData.gale1b.channel(i).doppler.';
    DopplerFGI = DopplerFGI(4:4:end, :)./1000; %Hz to kHz

    plot(axis, DopplerFGI, '.',"Color","blue");
    hold off;

    xlim([0 50])
    xlabel("Time (s)");
    if(i==1 || i==6)
        ylabel("Doppler (kHz)");
    end
    title("PRN"+labels(i) + " Advanced");
    
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
