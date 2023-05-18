clc;
clear all;
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

DopplerSkydel = DopplerSkydel(1:496,:);

labels =["01" "02" "03" "04" "05" "07" "08" "09" "11" "12"];

tiledlayout(row,column)
for i=1:num_sats
    
    nexttile;
    axis = 1:4:50000;
    DopplerFGI=trackData.gale1b.channel(i).doppler.';
    DopplerFGI = DopplerFGI(4:4:end, :);

    plot(axis, DopplerFGI, '.');
    hold on;
    


    axis = 500:100:50000;
    plot(axis, DopplerSkydel(:,i), '.');
    hold off;

    xlim([1 50000])
    title("Doppler for PRN"+labels(i));
    
end
