clc;
clear all;
close all;
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler01.txt');
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler02.txt');
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler03.txt');
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler04.txt');
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler05.txt');
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler07.txt');
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler08.txt');
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler09.txt');
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler11.txt');
load('./FGI-GSRx-main/exceldata/LEO200km/Doppler12.txt');

file="BigLeo_200km_results.mat";
row=2;
column=5;
num_sats=10;


load(file);

DopplerSkydel = [Doppler01 Doppler02 Doppler03 Doppler04 Doppler05 Doppler07 Doppler08 Doppler09 Doppler11 Doppler12];

DopplerSkydel = DopplerSkydel(1:496,:)./1000; %Hz to kHz

labels =["01" "02" "03" "04" "05" "07" "08" "09" "11" "12"];

tiledlayout(row,column)
for i=1:num_sats
    
    axis = 500/1000:100/1000:50000/1000; %ms to s


    nexttile;
    plot(axis, DopplerSkydel(:,i), '.',"Color","blue");
    hold on;
    
    axis = 1/1000:4/1000:50000/1000; %Hz to kHz
    DopplerFGI=trackData.gale1b.channel(i).doppler.';
    DopplerFGI = DopplerFGI(4:4:end, :)./1000; %Hz to kHz

    plot(axis, DopplerFGI, '.',"Color","green");
    hold off;

    xlim([0 50])
    ylim([-40 40]);
    xlabel("Time (s)");
    if(i==1 || i==6)
        ylabel("Doppler (kHz)");
    end
    title("PRN"+labels(i));
    title("PRN"+labels(i)+" (200km)");
    
end
