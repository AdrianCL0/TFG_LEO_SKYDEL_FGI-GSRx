clc;
clear all;
load('Drift01.txt');
load('Drift02.txt');
load('Drift03.txt');
load('Drift04.txt');
load('Drift05.txt');
load('Drift07.txt');
load('Drift08.txt');
load('Drift09.txt');
load('Drift11.txt');
load('Drift12.txt');


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
    axis = 1:4:50000;
    DriftFGI=trackData.gale1b.channel(i).prevIR2_PLL.';
    DriftFGI = DriftFGI(4:4:end, :);
    DriftFGI=DriftFGI(1:end-1);

    plot(axis,DriftFGI, '.');
    hold on;
    

    axis = 500:100:50000;

    plot(axis, DriftSkydel(:,i), '.');
    hold off;

    ylim([-500 100])
    xlim([1 50000]);
    title("Drift for PRN"+labels(i));
    
end
