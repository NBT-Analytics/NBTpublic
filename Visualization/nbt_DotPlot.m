% DotPlot function - makes a dot-plot
% PlotHandle = DotPlot(PlotHandle,xSpotGroupDistance, xSpotMeanDistance, PairedSwitch,FuncHandle,varargin)
% Input:
% PlotHandle : an axes handle for plotting, or a figure nr/figure handle
% xSpotGroupDistance = space between groups of dots
% xSpotMeanDistance = distance between mean measure
% PairedSwitch = plots lines between dots for paired conditios
% FuncHandle = e.g. @mean to calculate mean across channels and over dots
% varargin : use following order: BiomarkerObject, subjectRange, ChannelRange
    %with  subjectRange is range to plot, ChannelRange is range of channels
    %to average using FuncHandle
%Aim
%xSpotGroupDistance = 0.1
%xSpotMeanDistance = 0.025
%% Copyright (c) 2009,  Simon-Shlomo Poil (Center for Neurogenomics and Cognitive Research (CNCR), VU University Amsterdam)
%% ChangeLog -

function PlotHandle = nbt_DotPlot(PlotHandle,xSpotGroupDistance, xSpotMeanDistance, XRand, PairedSwitch,FuncHandle,Labels,StatTest,varargin)

% Figure handles
try
    axes(PlotHandle)
catch
    try
        figure(PlotHandle)
    catch
        figure
    end
    PlotHandle = gca;
end
xSpot = 0;
XTickIndex = [];
XTickLabelIndex = [];
Xindex = 0;

set(0,'DefaultAxesColorOrder',[0 0 1;0 0 1;0 0 1;1 0 0;1 0 0;1 0 0]); %set colors

MarkerList = {'o','d','s'};
MarkerIndex = 0;
Pairs =[];
LabelIndex = 0;

for Bid = 1:3:length(varargin) %for-loop biomarkers
    if (Bid == length(varargin)) 
        break
    end
    hold all
    
    xSpot = xSpot + xSpotGroupDistance; % Set spot to plot group dots
    Xindex = Xindex +1;
    
    %loop marker list
    MarkerIndex = MarkerIndex + 1;
    if(MarkerIndex > length(MarkerList)); MarkerIndex = 1;end
    
    BtoPlot  = varargin{Bid}; %biomarker to plot
    
    %Plot group dots
    plot(xSpot.*ones(length(varargin{Bid+1}),1)+XRand*randn(length(varargin{Bid+1}),1), FuncHandle(BtoPlot(varargin{Bid+2},varargin{Bid+1}),1),MarkerList{1,MarkerIndex}) 
    MinValue(Bid) = min(FuncHandle(BtoPlot(varargin{Bid+2},varargin{Bid+1}),1)); %to use for for setting axis value
    MaxValue(Bid) = max(FuncHandle(BtoPlot(varargin{Bid+2},varargin{Bid+1}),1));
    
    %Collect tickers
    XTickIndex = [XTickIndex xSpot];
    LabelIndex = LabelIndex +1;
    XTickLabelIndex{Xindex,1} =  Labels{LabelIndex,1};
    
    %Plot average measure using FuncHandle
    AverageValue = FuncHandle(FuncHandle(BtoPlot(varargin{Bid+2},varargin{Bid+1}),1),2);
    
    
    if((PairedSwitch == 0 && Xindex == 2) || (PairedSwitch ~= 0 && Xindex == 1))
        xSpotMeanDistance = -1*xSpotMeanDistance;
    end
    
    plot(xSpot+xSpotMeanDistance,AverageValue,MarkerList{1,MarkerIndex},'MarkerSize',8)
    
    
    switch StatTest
        case ''
            errorbar(xSpot+xSpotMeanDistance,AverageValue,nanstd(FuncHandle(BtoPlot(varargin{Bid+2},varargin{Bid+1}),1))/sqrt(length(find(~isnan(varargin{Bid+1})))),'MarkerSize',8)
        case 'boot'
            CI = nbt_bootciNonPara(5000, @nanmedian,FuncHandle(BtoPlot(varargin{Bid+2},varargin{Bid+1}),1));
            errorbar(xSpot+xSpotMeanDistance,AverageValue,AverageValue-CI(1), CI(2)-AverageValue,'MarkerSize',8)
    end
    
    xSpotMeanDistance = abs(xSpotMeanDistance);
    
    %Collect Pairs
    if PairedSwitch == 1
        Pairs =  [Pairs; FuncHandle(BtoPlot(varargin{Bid+2},varargin{Bid+1}),1)];
    end
end

if PairedSwitch ==1 % plot lines between dots
    for mm=varargin{2}
        plot(XTickIndex, Pairs,'k')
    end
end

% Adjust plot
box off
axis([0 xSpot+xSpotGroupDistance min(MinValue(1:3:length(varargin)))-0.1*min(MinValue(1:3:length(varargin))) max(MaxValue(1:3:length(varargin)))+0.1*max(MaxValue(1:3:length(varargin)))])
ylabel(Labels{LabelIndex+1,1})
set(gca,'XTick',XTickIndex)
set(gca,'XTickLabel',XTickLabelIndex)
end