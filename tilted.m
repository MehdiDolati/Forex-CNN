clc;
clear;
close all;

dataTable = readtable('koochik.csv','Format','%{yyyy.MM.dd HH:mm}D %f%f%f%f%d');
Data = table2timetable(dataTable);

ma1 = indicators(dataTable.Close ,'sma' , 8);
ma2 = indicators(dataTable.Close ,'sma' , 24);
ma3 = indicators(dataTable.Close ,'sma' , 120);
boll = indicators(dataTable.Close, 'rsi');

ii = 1;
inputWindowSize = 240;
t = tiledlayout(10,1);
mainT = tiledlayout(t, 1,1);
mainT.Layout.Tile = 1;
mainT.Layout.TileSpan=[9,1];
ax1= nexttile(mainT);

hold on;

plot(ma1(ii:ii + inputWindowSize), 'Blue');
plot(ma2(ii:ii + inputWindowSize), 'Green');
plot(ma3(ii:ii + inputWindowSize), 'Red');
candlestick_plot(Data(ii:ii + inputWindowSize,:), 1:inputWindowSize + 1, 'DownColor', 'Black', 'UpColor', 'White');
ax2= nexttile(t);
plot(boll(ii:ii + inputWindowSize), "Yellow");
linkaxes([ax1,ax2],'x');
xticklabels(ax1,{})
t.TileSpacing = 'none';

x0=10;
    y0=10;
    width=1280;
    height=768;
    set(gcf,'position',[x0,y0,width,height]);
%     exportgraphics(gca, "mamad.png");
    saveas(gca, "mamad.png");