load('PRN01.txt');
load('PRN02.txt');
load('PRN03.txt');
load('PRN04.txt');
load('PRN05.txt');
load('PRN07.txt');

load("LEO_default_track_result.mat");

channels = [PRN01 PRN02 PRN03 PRN04 PRN05 PRN07];

channels = channels(1:496,:);

labels =["PRN01" "PRN02" "PRN03" "PRN04" "PRN05" "PRN07"];

tiledlayout(2,3)
for i=1:6
    
    axis = 500:100:50000;
    
    %     figure;
    nexttile;
    plot(axis, channels(:,i), '.');
    hold on;
    
    axis = 1:4:50000;
    PRNfgi=trackData.gale1b.channel(i).doppler.';
    PRNfgi = -PRNfgi(4:4:end, :);

    plot(axis, PRNfgi, '.');
    hold off;

    legend(["Doppler Skydel" "Doppler FGI Default"]);
    title(labels(i)+ " Default");
    
end

load("LEO_advanced_track_result.mat");

figure;
tiledlayout(2,3)
for i=1:6

    axis = 500:100:50000;

    %     figure;
    nexttile;
    plot(axis, channels(:,i), '.');
    hold on;

    axis = 1:4:50000;
    PRNfgi=trackData.gale1b.channel(i).doppler.';
    PRNfgi = -PRNfgi(4:4:end, :);

    plot(axis, PRNfgi, '.');
    hold off;

    legend(["Doppler Skydel" "Doppler FGI Advanced"]);
    title(labels(i) + " Advanced");
    
end




