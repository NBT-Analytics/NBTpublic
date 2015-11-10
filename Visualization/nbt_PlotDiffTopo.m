
function nbt_PlotDiffTopo(diff_b, p, TextInfo, Unit, inlow, inhigh,statfuncname,DiffSwitch, SignalInfo)

%% initial setup
fontsize=8;
% get figure handle for topoplot
figHandle = findobj('Tag','nbt_PlotDiffTopoFig');
if(isempty(figHandle))
    figure()
    set(gcf,'Tag','nbt_PlotDiffTopoFig');
else
    figure(figHandle)
end
clf
%load color map
coolWarm = load('nbt_CoolWarm.mat','coolWarm');
coolWarm = coolWarm.coolWarm;
colormap(coolWarm)
%%%%%%%%%%%%%%%%%%
if strcmp(statfuncname,'ttest')
    meanlow  = nanmean(diff_b(:,inlow),2);
    meanhigh = nanmean(diff_b(:,inhigh),2);
else
    meanlow  = nanmedian(diff_b(:,inlow),2);
    meanhigh = nanmedian(diff_b(:,inhigh),2);
end

for ppp = 1:size(diff_b,2)
    [individualRegions(:,ppp) ChannelsRegion] = nbt_get_regions(diff_b(:,ppp),[], SignalInfo);
end

if strcmp(statfuncname,'ttest')
    meanlow_regions  = nanmean(individualRegions(:,inlow),2)';
    meanhigh_regions = nanmean(individualRegions(:,inhigh),2)';
else
    meanlow_regions  = nanmedian(individualRegions(:,inlow),2)';
    meanhigh_regions = nanmedian(individualRegions(:,inhigh),2)';
end


if(DiffSwitch)
    cmax = max(abs([meanlow', meanhigh', meanlow_regions, meanhigh_regions]));
    cmin=-1*cmax;
else
    cmax = max( [meanlow', meanhigh', meanlow_regions, meanhigh_regions]);
    cmin = min( [meanlow', meanhigh', meanlow_regions, meanhigh_regions]);
end

%% positive difference
subplot(5,3,4)
topoplot(meanlow',SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
cb = colorbar('westoutside');
set(get(cb,'title'),'String',Unit);
caxis([cmin,cmax])

subplot(5,3,5)
nbt_plot_EEG_channels(meanlow,cmin,cmax,SignalInfo.Interface.EEG.chanlocs)
axis square
cb = colorbar('westoutside');
set(get(cb,'title'),'String',Unit);
caxis([cmin,cmax])
set(gca,'fontsize',fontsize)

subplot(5,3,6)
nbt_plot_subregions(meanlow_regions,1,cmin,cmax,ChannelsRegion)
cb = colorbar('westoutside');
set(get(cb,'title'),'String',Unit);
caxis([cmin,cmax])
set(gca,'fontsize',fontsize)

%% Negative difference
subplot(5,3,7)
topoplot(meanhigh',SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
cb = colorbar('westoutside');
set(get(cb,'title'),'String',Unit);
caxis([cmin,cmax])

subplot(5,3,8)
nbt_plot_EEG_channels(meanhigh,cmin,cmax,SignalInfo.Interface.EEG.chanlocs)
axis square
cb = colorbar('westoutside');
set(get(cb,'title'),'String',Unit);
caxis([cmin,cmax])
set(gca,'fontsize',fontsize)

subplot(5,3,9)
nbt_plot_subregions(meanhigh_regions,1,cmin,cmax, ChannelsRegion)
cb = colorbar('westoutside');
set(get(cb,'title'),'String',Unit);
caxis([cmin,cmax])
set(gca,'fontsize',fontsize)
%%  difference Pos-neg



diffMean = meanhigh-meanlow;


    cmax = max(abs(diffMean));
    cmin = -cmax;


subplot(5,3,10)
topoplot(diffMean',SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
cb = colorbar('westoutside');
set(gca,'clim',[cmin cmax]);
set(get(cb,'title'),'String',Unit);



subplot(5,3,11)
nbt_plot_EEG_channels(diffMean,cmin,cmax,SignalInfo.Interface.EEG.chanlocs)
axis square
cb = colorbar('westoutside');
set(get(cb,'title'),'String',Unit);
caxis([cmin,cmax])
set(gca,'fontsize',fontsize)

diffRegions = meanhigh_regions - meanlow_regions;

subplot(5,3,12)
nbt_plot_subregions(diffRegions,1,cmin,cmax, ChannelsRegion)
cb = colorbar('westoutside');
set(get(cb,'title'),'String',Unit);
caxis([cmin,cmax])
set(gca,'fontsize',fontsize)

try
minPValue = -2;
maxPValue = -0.5;
subplot(5,3,13)
topoplot(log10(p),SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
cbh = colorbar('westoutside');
caxis([minPValue maxPValue])
%     axis equal
set(cbh,'YTick',[-2 -1.3010 -1 0])
set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
set(gca,'fontsize',fontsize)

% p values
subplot(5,3,14)
nbt_plot_EEG_channels(log10(p),minPValue,maxPValue,SignalInfo.Interface.EEG.chanlocs)
 axis square
cbh = colorbar('westoutside');
caxis([minPValue maxPValue])
%     axis equal
set(cbh,'YTick',[-2 -1.3010 -1 0])
set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
set(gca,'fontsize',fontsize)
catch
end

for j = 1:6
    if strcmp(statfuncname,'ttest')
        [dummy,pR(j),dummy]=ttest2(individualRegions(j,inlow),individualRegions(j,inhigh));
    else
        %pR(j)=ranksum(individualRegions(j,inlow),individualRegions(j,inhigh));
        [pR(j), mean_difference, N_s, p_low, p_high]=nbt_permutationtest(individualRegions(j,inlow),individualRegions(j,inhigh),5000,0,@nanmedian);
    end
end

subplot(5,3,15)

nbt_plot_subregions(log10(pR),1,minPValue,maxPValue, ChannelsRegion)
cbh = colorbar('westoutside');
caxis([minPValue maxPValue])
%     axis equal
set(cbh,'YTick',[-2 -1.3010 -1 0])
set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
set(gca,'fontsize',fontsize)




%% add Info to plot
B1FirstLine  = TextInfo{1,1};
B1SecondLine = TextInfo{2,1};
B2FirstLine = TextInfo{3,1};
B2SecondLine = TextInfo{4,1};
DiffFirstLine = TextInfo{5,1};
DiffSecondLine = TextInfo{6,1};
PFirstLine = TextInfo{7,1};
PSecondLine = TextInfo{8,1};




y=0.1;
subplot(5,3,1)
text(0.5,y,'Interpolated topoplot','horizontalalignment','center')
text(-0.23,   -0.8469,B1FirstLine,'horizontalalignment','center','interp','none')
text(-0.23,   -1,B1SecondLine,'horizontalalignment','center')
text(-0.23,   -1.1571,['\it{n} = ' num2str(length(inlow))],'horizontalalignment','center');

text(-0.23,   -2.2619 ,B2FirstLine,'horizontalalignment','center','interp','none')
text(-0.23,   -2.41  ,B2SecondLine,'horizontalalignment','center')
text(-0.23,   -2.5671,['\it{n} = ' num2str(length(inhigh))],'horizontalalignment','center');

text(-0.23,   -3.6429 ,DiffFirstLine,'horizontalalignment','center','interp','none')
text(-0.23,   -3.8 ,DiffSecondLine,'horizontalalignment','center')

text(-0.23,   -5.0429 ,PFirstLine,'horizontalalignment','center','interp','none')
text(-0.23,   -5.2 ,PSecondLine,'horizontalalignment','center')


axis off
subplot(5,3,2)
text(0.5,y,'Actual channels','horizontalalignment','center')
axis off
subplot(5,3,3);
if strcmp(statfuncname,'ttest')
    text(0.5,y,['Means per subregion'],'horizontalalignment','center')
else
    text(0.5,y,['Medians per subregion'],'horizontalalignment','center')
end
axis off

subplot(5,3,14)
title('right click on channels to plot errorbars')

subplot(5,3,15)
title('right click on channels to plot errorbars')

end
    