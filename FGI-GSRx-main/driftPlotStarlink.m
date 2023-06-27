clc;
clear all;
close all;
load('./FGI-GSRx-main/exceldata/Starlink/Drift01.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Drift02.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Drift03.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Drift04.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Drift05.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Drift07.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Drift08.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Drift09.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Drift11.txt');
load('./FGI-GSRx-main/exceldata/Starlink/Drift12.txt');


file="BigLeoStarlink_results_100.mat";
row=2;
column=5;
num_sats=10;


load(file);

DriftSkydel = [Drift01 Drift02 Drift03 Drift04 Drift05 Drift07 Drift08 Drift09 Drift11 Drift12];

DriftSkydel = DriftSkydel(1:496,:);

labels =["01" "02" "03" "04" "05" "07" "08" "09" "11" "12"];

tiledlayout(row,column)
for i=1:num_sats

    nexttile;

    axis = 1/1000:4/1000:50000/1000; %ms to s
    DriftFGI=trackData.gale1b.channel(i).prevIR2_PLL.';
    DriftFGI = DriftFGI(4:4:end, :);
    DriftFGI=DriftFGI(1:end-1); 

    plot(axis,DriftFGI, '.',"Color","blue");
    hold on;

    axis = 500/1000:100/1000:50000/1000;

    plot(axis, DriftSkydel(:,i), '.',"Color","green");
    hold off;

    ylim([-500 100])
    xlim([0 50]);
    xlabel("Time (s)");
    if(i==1 || i==6)
        ylabel("Drift (Hz/s)");
    end
    title("PRN"+labels(i));
    
end
