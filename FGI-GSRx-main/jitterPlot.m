clc;
clear all;
load('Jitter01.txt');
load('Jitter02.txt');
load('Jitter03.txt');
load('Jitter04.txt');
load('Jitter05.txt');
load('Jitter07.txt');
load('Jitter08.txt');
load('Jitter09.txt');
load('Jitter11.txt');
load('Jitter12.txt');


file="BigLeoStarlink_results_100.mat";
row=2;
column=5;
num_sats=10;


load(file);

JitterSkydel = [Jitter01 Jitter02 Jitter03 Jitter04 Jitter05 Jitter07 Jitter08 Jitter09 Jitter11 Jitter12];

JitterSkydel = JitterSkydel(1:496,:);

labels =["01" "02" "03" "04" "05" "07" "08" "09" "11" "12"];

tiledlayout(row,column)
for i=1:num_sats

    nexttile;
    axis = 1:4:50000;
    JitterFGI=trackData.gale1b.channel(i).jitter.';
    JitterFGI = JitterFGI(4:4:end, :);
    JitterFGI=JitterFGI(1:end-1);

    plot(axis,JitterFGI, '.');
    hold on;
    

    axis = 500:100:50000;

    plot(axis, JitterSkydel(:,i), '.');
    hold off;

    xlim([1 50000]);
    ylim([-1000 1000])
    title("Jitter for PRN"+labels(i));
    
end
