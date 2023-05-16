clc;
clear all;
load('Doppler01.txt');
load('Doppler02.txt');
load('Doppler03.txt');
load('Doppler04.txt');
load('Doppler05.txt');
load('Doppler07.txt');
load('Doppler08.txt');
load('Doppler09.txt');
load('Doppler11.txt');
load('Doppler12.txt');

file="BigLeoStarlink_results_100.mat";
row=2;
column=5;
num_sats=10;


load(file);

DopplerSkydel = [Doppler01 Doppler02 Doppler03 Doppler04 Doppler05 Doppler07 Doppler08 Doppler09 Doppler11 Doppler12];

DopplerSkydel = DopplerSkydel(1:496,:);

labels =["01" "02" "03" "04" "05" "07" "08" "09" "11" "12"];

tiledlayout(row,column)
for i=1:num_sats
    
    axis = 500:100:50000;


    nexttile;
    plot(axis, DopplerSkydel(:,i), '.');
    hold on;
    
    axis = 1:4:50000;
    DopplerFGI=trackData.gale1b.channel(i).doppler.';
    DopplerFGI = DopplerFGI(4:4:end, :);

    plot(axis, DopplerFGI, '.');
    hold off;

    xlim([1 50000])
    title("Doppler for PRN"+labels(i));
    
end
