clc;
clear all;
close all;
load('./FGI-GSRx-main/exceldata/Starlink/Doppler01.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Doppler02.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Doppler03.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Doppler04.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Doppler05.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Doppler07.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Doppler08.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Doppler09.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Doppler11.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Doppler12.txt');

file="BigLeoStarlink_results_100.mat";
row=2;
column=5;
num_sats=10;


load(file);

DopplerSkydel = [Doppler01 Doppler02 Doppler03 Doppler04 Doppler05 Doppler07 Doppler08 Doppler09 Doppler11 Doppler12];

DopplerSkydel = DopplerSkydel(1:496,:)./1000; %Hz to kHz

labels =["01" "02" "03" "04" "05" "07" "08" "09" "11" "12"];

tiledlayout(row,column)
for i=1:num_sats
    
    nexttile;
    axis = 1/1000:4/1000:50000/1000; %ms to s
    DopplerFGI=trackData.gale1b.channel(i).doppler.';
    DopplerFGI = DopplerFGI(4:4:end, :)./1000; %Hz to kHz

    plot(axis, DopplerFGI, '.',"Color","blue");
    hold on;
    


    axis = 500/1000:100/1000:50000/1000; %ms to s
    plot(axis, DopplerSkydel(:,i), '.',"Color","green");
    hold off;

    xlim([0 50])
    ylim([-35 35]);
    xlabel("Time (s)");
    if(i==1 || i==6)
        ylabel("Doppler (kHz)");
    end
    title("PRN"+labels(i));
    
end
