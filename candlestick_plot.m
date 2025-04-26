function candlestick_plot(data,time,varargin)
% candlestick_plot(high,low,opening,closing,time,varargin) by PA-CHAUVENET
%
% V1.0
% Draw a chart representing market's opening, high, low, and closing price
% of a specific time range.
% Candle body represents the price range between the open and close while 
% sticks represents the price range between the high and low
%
% candlestick_plot(high,low,opening,closing,time,'Theme','Dark','DownColor','b')

% optionnal argument default values
DownColor = 'r';
UpColor   = [0.3922    0.8314    0.0745];
Theme     = 'Clear';
ylabel_txt = '';
% custom_legend = 'signal';

%% optionnal argument management 
fixed_argument_nb = 2;
optionnal_arg_nb = nargin - fixed_argument_nb;
for i = 1:optionnal_arg_nb
    if strcmp(varargin{i},'DownColor')
        DownColor = varargin{i+1};
    end
    if strcmp(varargin{i},'UpColor')
        UpColor = varargin{i+1};
    end
    if strcmp(varargin{i},'Theme')
        Theme = varargin{i+1};
    end
    if strcmp(varargin{i},'Ylabel')
        ylabel_txt = varargin{i+1};
    end
end

% options
DataWidth = time(1)-time(2);
Cwidth    = DataWidth/3; % candle time width
%fig = figure;
hold on
for i = 1:length(data.High)
    x = [time(i)-Cwidth time(i)-Cwidth time(i)+Cwidth time(i)+Cwidth time(i)-Cwidth];
    y = [data.Open(i) data.Close(i) data.Close(i) data.Open(i) data.Open(i)];
    if data.Close(i) > data.Open(i) % UP
        line([time(i) time(i)],[data.Low(i) data.High(i)],'color',UpColor);
        fill(x,y,UpColor)
        
    else % DOWN
        line([time(i) time(i)],[data.Low(i) data.High(i)],'color',DownColor);
        fill(x,y,DownColor);
        
    end
end
hold off
grid
ax = gca;
ax.YAxis.Exponent = 0;
ax.YMinorGrid = 'on';
ylabel(ylabel_txt);

if strcmp(Theme,'Dark')
% dark theme
fig.Color = [0.3216    0.3216    0.3216];
ax.Color = [0.2392    0.2392    0.2392];
ax.GridColor = [0.9412    0.9412    0.9412];
ax.XColor = [0.9412    0.9412    0.9412];
ax.YColor = [0.9412    0.9412    0.9412];
end
% eof