clc;
clear all;
close all;
load('Jerk01.txt');
load('Jerk02.txt');
load('Jerk03.txt');
load('Jerk04.txt');
load('Jerk05.txt');
load('Jerk07.txt');
load('Jerk08.txt');
load('Jerk09.txt');
load('Jerk11.txt');
load('Jerk12.txt');


file="BigLeoStarlink_results_100.mat";
row=2;
column=5;
num_sats=10;


load(file);

JerkSkydel = [Jerk01 Jerk02 Jerk03 Jerk04 Jerk05 Jerk07 Jerk08 Jerk09 Jerk11 Jerk12];

JerkSkydel = JerkSkydel(1:496,:);

labels =["01" "02" "03" "04" "05" "07" "08" "09" "11" "12"];

tiledlayout(row,column)
for i=1:num_sats

    nexttile;
    if(mod(i,2)==0)
        axis = 1/1000:4/1000:50000/1000; %ms to s
        JerkFGI=trackData.gale1b.channel(i).jerk.';
        JerkFGI = JerkFGI(4:4:end, :);
        JerkFGI=JerkFGI(1:end-1);
    
        plot(axis,JerkFGI, '.',"color","blue");
        hold on;
    end

    axis = 500/1000:100/1000:50000/1000; %ms to s
    plot(axis, JerkSkydel(:,i), '.',"color","green");

    if(mod(i,2)==0)
        hold off;
        xlim([0 50]);
        ylim([-1000 1000])
    else
        xlim([0 50]);
        ylim([-12 12])
    end

    xlabel("Time (s)");
    if(i==1 || i==6)
        ylabel("Jerk (Hz/s^2)");
    end
    title("PRN"+labels(i));
    
end
