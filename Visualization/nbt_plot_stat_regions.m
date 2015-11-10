% nbt_plot_stat_regions - Plot statistics 
%
% Usage:
%   nbt_plot_stat_regions(SignalInfo,statdata,biomarker,unit)
%   or
%   nbt_plot_stat_regions(SignalInfo,statdata,biomarker,unit,cond1,cond2)
%
% Inputs:
%   SignalInfo
%   statdata   is a struct containing is created by nbt_selectstatistics
%             statdata.test % test name
%             statdata.statistic % statisticcs (ie. @nanmean)
%             statdata.func % statistic function (i.e. @ttest)
%             statdata.p % p-values
%             statdata.C % confidence interval
%             statdata.meanc1;
%             statdata.mean_c1_regions;
%             statdata.C_regions;% confidence interval per regions
%             statdata.c1_regions;
%             statdata.c1 = c1;
%  biomarker biomarker name (string)
%   unit string
%   cond1,cond2   string (i.s. 'ECR1')
%
% Outputs:
%   plot   
%
% Example:
%   nbt_plot_stat_regions(SignalInfo,statdata,biomarker,unit)
%
% References:
% 
% See also: 
%           nbt_selectstatistics
%  
  
%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2012), see NBT website
% (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) <year>  <Main Author>  (Neuronal Oscillations and Cognition group, 
% Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, 
% Neuroscience Campus Amsterdam, VU University Amsterdam)
%
% Part of the Neurophysiological Biomarker Toolbox (NBT)
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
%
% See Readme.txt for additional copyright information.
% -------------------------------------------------------------------------


function nbt_plot_stat_regions(varargin)
P=varargin;
nargs=length(P);
SignalInfo = P{1};
statdata = P{2};
biomarker = P{3};
unit = P{4};
if (nargs<5 || isempty(P{5})) 
    cond1 = [];
    cond2 = [];
else
    cond1 = P{5}; 
    cond2 = P{6};
end;
fontsize =8;
if ~isfield(statdata, 'c2') %for within group
%--------------------------------------------------------------------------
    meanc1 = statdata.meanc1;
    vmax=max(meanc1);
    vmin=min(meanc1);
    
    try
        mean_c1_regions = statdata.mean_c1_regions;
        C_regions = statdata.C_regions;
        c1_regions = statdata.c1_regions;

        rmax=max(mean_c1_regions);
        rmin=min(mean_c1_regions);
        cmax = max([vmax, rmax]);
        cmin = min([vmin, rmin]);

    catch
           cmax = vmax; 
            cmin = vmin;
    end
        

    figure('name',['NBT: Statistics for ',regexprep(biomarker,'_',' ')],'NumberTitle','off')
    set(gcf,'position',[1          31       1280      920]) %128

    % -- plot grand average per channel:
    xa=-2;
    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
    coolWarm = coolWarm.coolWarm;
    colormap(coolWarm);
    subplot(2,4,5)
    topoplot(meanc1',SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)

    subplot(2,4,6)
    nbt_plot_EEG_channels(meanc1,cmin,cmax,SignalInfo.Interface.EEG.chanlocs)
    axis equal
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)

    %--- plot grand average subregions
    try
    subplot(2,4,7)
    nbt_plot_subregions(mean_c1_regions,1,cmin,cmax)
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)

    
    %--- Plot errorbars per region
    region{1}='frontal';
    region{2}='left temporal';
    region{3}='central';
    region{4}='right temporal';
    region{5}='parietal';
    region{6}='occipital';
    C_regions = C_regions';
    diff_regions=mean(C_regions);
    subplot(2,4,8)
    errorbar(1:6,diff_regions,(C_regions(2,:)-C_regions(1,:))/2,'linestyle','none', ...
            'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff_regions,'r.','Markersize',10)
    plot(1.2:6.2,c1_regions','.k')
    ylim1=get(gca,'ylim');
    for i=1:6
        text(i,ylim1(1),region{i},'rotation',45,'horizontalalignment','right','fontsize',fontsize)
    end
    ylabel(unit,'verticalalignment','baseline','position',[7,ylim1(1)+(ylim1(2)-ylim1(1))/2])
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)

    catch
    end
    
    %---                            add Info to plot
    y=0.1;
    subplot(2,4,1)
    text(0.5,y,'Interpolated topoplot','horizontalalignment','center')
    axis off

    subplot(2,4,3);text(0.5,y,[cell2mat(statdata.test),' per subregions'],'horizontalalignment','center')
    axis off

    subplot(2,4,2)
    text(0.5,y,'Actual channels','horizontalalignment','center')
    axis off

    subplot(2,4,4);text(0.5,y,['Errorbars and ',cell2mat(statdata.test),' per subregion'],'horizontalalignment','center')
    axis off

    subplot(2,4,2)
    title(['Statistics for ',regexprep(biomarker,'_',' ')],'interpreter','none');
    %--------------------------------------------------------------------------

elseif isfield(statdata, 'c2') && isempty(cond1)%for between groups
    figure('name',['NBT: Statistics for ',regexprep(biomarker,'_',' ')],'NumberTitle','off')
    set(gcf,'position',[1          31       1280      920]) %128
    meanc1 = statdata.meanc1;
    meanc2 = statdata.meanc2;
    p_biomarkers = statdata.p;
    Diffc2c1 = statdata.Diffc2c1;
    c1 = statdata.c1;
    c2 = statdata.c2;
    C = statdata.C;
 
    statistic = statdata.statistic;

try
    mean_c1_regions = statdata.mean_c1_regions;
    mean_c2_regions = statdata.mean_c2_regions;
    C_regions = statdata.C_regions;
    p_regions = statdata.p_regions;
    c1_regions = statdata.c1_regions;
    c2_regions = statdata.c2_regions;
catch
end

    % ---for color scale in following plots
    vmax=max([meanc1,meanc2]);
    vmin=min([meanc1,meanc2]);
try
    rmax=max([mean_c1_regions,mean_c2_regions]);
    rmin=min([mean_c1_regions,mean_c2_regions]);
    cmax = max([vmax, rmax]);
    cmin = min([vmin, rmin]);
catch
cmax = max(vmax);
cmin = min(vmin);
end

    % ---plot grand average group 1 per channel:

    xa=-2;
    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
    coolWarm = coolWarm.coolWarm;
    colormap(coolWarm);
    subplot(4,4,5)
    topoplot(meanc1',SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
    colorbar('westoutside')
    caxis([cmin,cmax])

    textThis = sprintf('Grand average for group 1');
    nbt_split_text(xa,0.15,textThis,20,fontsize);
    set(gca,'fontsize',fontsize)

    subplot(4,4,6)
    nbt_plot_EEG_channels(meanc1,cmin,cmax,SignalInfo.Interface.EEG.chanlocs)
    axis equal
    colorbar('westoutside')
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)

    % --- plot grand average group 1 subregions
    try
    subplot(4,4,7)
    nbt_plot_subregions(mean_c1_regions,1,cmin,cmax)
    colorbar('westoutside')
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    catch
    end
    % ---plot grand average group 2 per channel:

    subplot(4,4,9)
    topoplot(meanc2',SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
    colorbar('westoutside')
    caxis([cmin,cmax])

    textThis = sprintf('Grand average for group 2');
    nbt_split_text(xa,0.15,textThis,20,fontsize);
    set(gca,'fontsize',fontsize)

    subplot(4,4,10)
    nbt_plot_EEG_channels(meanc2,cmin,cmax,SignalInfo.Interface.EEG.chanlocs)
    axis equal
    colorbar('westoutside')
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)

    % --- plot grand average group2 subregions
    try
    subplot(4,4,11)
    nbt_plot_subregions(mean_c2_regions,1,cmin,cmax)
    colorbar('westoutside')
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    catch
    end
    
    % --- Plot log10(P-Values) to trick colour bar
    minPValue = -2;
    maxPValue = -0.5;
    subplot(4,4,14)
    nbt_plot_EEG_channels(log10(p_biomarkers),minPValue,maxPValue,SignalInfo.Interface.EEG.chanlocs);
    cbh = colorbar('westoutside');
    caxis([minPValue maxPValue])
    axis equal
    set(cbh,'YTick',[-2 -1.3010 -1 0])
    set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
    a=get(gca,'xlim');
    b=get(gca,'ylim');
    text(a(1),b(1)-(b(2)-b(1))/10,'P-values','horizontalalignment','right')
    set(gca,'fontsize',fontsize)

    % --- Plot difference group 1 vs group 2 per channel
    subplot(4,4,13)
    topoplot(statistic(Diffc2c1,2),SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
    colorbar('westoutside')
    textThis = sprintf('Grand average for group 2 minus group 1');
    nbt_split_text(xa,0.15,textThis,20,fontsize);
    axis off
    set(gca,'fontsize',fontsize)


    % ---plot p-values per subregion
try
    subplot(4,4,15)
    nbt_plot_subregions(log10(p_regions),1,minPValue,maxPValue);
    cbh = colorbar('westoutside');
    caxis([minPValue maxPValue])
    axis equal
    set(cbh,'YTick',[-2 -1.3010 -1 0])
    set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
    a=get(gca,'xlim');
    b=get(gca,'ylim');
    text(a(1),b(1)-(b(2)-b(1))/10,'P-values','horizontalalignment','right')
    set(gca,'fontsize',fontsize)

    % ---Plot group 1 errorbars per region
    region{1}='frontal';
    region{2}='left temporal';
    region{3}='central';
    region{4}='right temporal';
    region{5}='parietal';
    region{6}='occipital';
    C1 = C1';
    diff1=statistic(C1);
    subplot(4,4,8)
    errorbar(1:6,diff1,(C1(2,:)-C1(1,:))/2,'linestyle','none', ...
            'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff1,'r.','Markersize',10)
    plot(1.2:6.2,c1_regions','.k')
    ylim1=get(gca,'ylim');
    ylabel('\muV','verticalalignment','baseline','position',[7,ylim1(1)+(ylim1(2)-ylim1(1))/2])
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)

    % --- Plot group 2 errorbars per region
    C2 = C2'; 
    diff2=statistic(C2);
    subplot(4,4,12)
    errorbar(1:6,diff2,(C2(2,:)-C2(1,:))/2,'linestyle','none', ...
            'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff2,'r.','Markersize',10)
    plot(1.2:6.2,c2_regions','.k')
    ylim2=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)

    % --- set axis equal for two groups

    maxylim=max(ylim1(2),ylim2(2));
    minylim=max(ylim1(1),ylim2(1));
    set(gca,'ylim',[minylim,maxylim])
    for i=1:6
        text(i,minylim,region{i},'rotation',45,'horizontalalignment','right','fontsize',8)
    end

    subplot(4,4,8)
    set(gca,'ylim',[minylim,maxylim])
    for i=1:6
        text(i,minylim,region{i},'rotation',45,'horizontalalignment','right','fontsize',8)
    end
    C_regions = C_regions';
    diff=statistic(C_regions);
    subplot(4,4,16)
    errorbar(1:6,diff,(C_regions(2,:)-C_regions(1,:))/2,'linestyle','none', ...
            'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff,'r.','Markersize',10)
    plot(1.2:6.2,c2_regions' - c1_regions','.k')
    ylim1=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)
    ax=get(gca,'ylim');
    for i=1:6
        text(i,ax(1),region{i},'rotation',45,'horizontalalignment','right','fontsize',8)
    end
catch
end
    %  --- add Info to plot
    y=0.1;
    subplot(4,4,1)
    text(0.5,y,'Interpolated topoplot','horizontalalignment','center')
    axis off

    subplot(4,4,3);text(0.5,y,[cell2mat(statdata.test),' per subregions'],'horizontalalignment','center')
    axis off

    subplot(4,4,2)
    textThis = sprintf('Statistics for difference in "%s" between group 1 and group 2',regexprep(biomarker,'_',' '));
    % nbt_split_title([0.5 0.5],textThis,90,11);
    title(textThis);
    text(0.5,y,'Actual channels','horizontalalignment','center')
    axis off

    subplot(4,4,4);text(0.5,y,['Errorbars and ',cell2mat(statdata.test),' per subregion'],'horizontalalignment','center')
    axis off

%--------------------------------------------------------------------------
elseif isfield(statdata, 'c2') && ~isempty(cond1)%for between groups
    
    figure('name',['NBT: Statistics for ',regexprep(biomarker,'_',' ')],'NumberTitle','off')
    set(gcf,'position',[1          31       1280      920]) %128
    meanc1 = statdata.meanc1;
    meanc2 = statdata.meanc2;
    mean_c1_regions = statdata.mean_c1_regions;
    mean_c2_regions = statdata.mean_c2_regions;
    p_channels = statdata.p;
    diffC2C1 = statdata.diffC2C1;
    statistic = statdata.statistic;
    p_regions = statdata.p_regions;
   % C1 = statdata.C1;
  %  C2 = statdata.C2;
    C_regions = statdata.C_regions;
    c1_regions = statdata.c1_regions;
    c2_regions = statdata.c2_regions;
    c1 = statdata.c1;
    c2 = statdata.c2;
    % ---for color scale in following plots
    vmax=max([meanc1,meanc2]);
    vmin=min([meanc1,meanc2]);
    rmax=max([mean_c1_regions,mean_c2_regions]);
    rmin=min([mean_c1_regions,mean_c2_regions]);
    cmax = max([vmax, rmax]);
    cmin = min([vmin, rmin]);


%--- plot grand average condition 1 per channel:
    xa=-2;
    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
    coolWarm = coolWarm.coolWarm;
    colormap(coolWarm);
    subplot(4,4,5)
    topoplot(meanc1',SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    
    textThis = sprintf('Grand average for condition: %s',cond1);
    nbt_split_text(xa,0.15,textThis,20,fontsize);
    set(gca,'fontsize',fontsize)
    
    subplot(4,4,6)
    nbt_plot_EEG_channels(meanc1,cmin,cmax,SignalInfo.Interface.EEG.chanlocs)
    axis square
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    
%--- plot grand average condition 1 subregions
    subplot(4,4,7)
    nbt_plot_subregions(mean_c1_regions,1,cmin,cmax)
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    
%---   plot grand average condition 2:
    
    subplot(4,4,9)
    topoplot(meanc2',SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    
    textThis = sprintf('Grand average for condition: %s',cond2);
    nbt_split_text(xa,0.15,textThis,20,fontsize);
    set(gca,'fontsize',fontsize)
    
    subplot(4,4,10)
    nbt_plot_EEG_channels(meanc2,cmin,cmax,SignalInfo.Interface.EEG.chanlocs)
    axis square
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    
    
% --- plot grand average subregions
    subplot(4,4,11)
    nbt_plot_subregions(mean_c2_regions,1,cmin,cmax)
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    
% --- Plot log10(P-Values) to trick colour bar
    minPValue = -2;
    maxPValue = -0.5;
    subplot(4,4,14)
    nbt_plot_EEG_channels(log10(p_channels),minPValue,maxPValue,SignalInfo.Interface.EEG.chanlocs);
    cbh = colorbar('westoutside');
    
    caxis([minPValue maxPValue])
    axis equal
    set(cbh,'YTick',[-2 -1.3010 -1 0])
    set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
    a=get(gca,'xlim');
    b=get(gca,'ylim');
    text(a(1),b(1)-(b(2)-b(1))/10,'P-values','horizontalalignment','right')
    set(gca,'fontsize',fontsize)
    
% --- Plot Difference per channel
    subplot(4,4,13)
    topoplot(statistic(diffC2C1,2),SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    textThis = sprintf('Grand average for condition %s minus condition %s',cond2,cond1);
    nbt_split_text(xa,0.15,textThis,20,fontsize);
    axis off
    set(gca,'fontsize',fontsize)
    
%--- plot p-values per subregion
    
    subplot(4,4,15)
    nbt_plot_subregions(log10(p_regions),1,minPValue,maxPValue);
    
    cbh = colorbar('westoutside');
    caxis([minPValue maxPValue])
    axis square
    set(cbh,'YTick',[-2 -1.3010 -1 0])
    set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
    a=get(gca,'xlim');
    b=get(gca,'ylim');
    text(a(1),b(1)-(b(2)-b(1))/10,'P-values','horizontalalignment','right')
    set(gca,'fontsize',fontsize)
    
%--- Plot condition 1 errorbars per region
    region{1}='frontal';
    region{2}='left temporal';
    region{3}='central';
    region{4}='right temporal';
    region{5}='parietal';
    region{6}='occipital';
    
    C1 = C1'; 
    diff1=statistic(C1);
    subplot(4,4,8)
    errorbar(1:6,diff1,(C1(2,:)-C1(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff1,'r.','Markersize',10)
    plot(1.2:6.2,c1_regions','.k')
    ylim1=get(gca,'ylim');
    ylabel(unit,'verticalalignment','baseline','position',[7,ylim1(1)+(ylim1(2)-ylim1(1))/2])
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)
    
    
% --- condition 2 errorbars per region
    C2 = C2';
    diff2=statistic(C2);
    subplot(4,4,12)
    errorbar(1:6,diff2,(C2(2,:)-C2(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff2,'r.','Markersize',10)
    plot(1.2:6.2,c2_regions','.k')
    ylim2=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)
    ylabel(unit,'verticalalignment','baseline','position',[7,ylim1(1)+(ylim1(2)-ylim1(1))/2])
    
%--- set axis equal for two conditions
    maxylim=max(ylim1(2),ylim2(2));
    minylim=max(ylim1(1),ylim2(1));
    set(gca,'ylim',[minylim,maxylim])
    for i=1:6
        text(i,minylim,region{i},'rotation',45,'horizontalalignment','right','fontsize',8)
    end
    subplot(4,4,8)
    set(gca,'ylim',[minylim,maxylim])
    for i=1:6
        text(i,minylim,region{i},'rotation',45,'horizontalalignment','right','fontsize',8)
    end
    
% ---test for difference: condition 2 - condition 1, plot errorbars per region   
    C_regions = C_regions';
    diff=statistic(C_regions);
    subplot(4,4,16)
    errorbar(1:6,diff,(C_regions(2,:)-C_regions(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff,'r.','Markersize',10)
    plot(1.2:6.2,c2_regions' - c1_regions','.k')
    ylim1=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)
    ax=get(gca,'ylim');
    for i=1:6
        text(i,ax(1),region{i},'rotation',45,'horizontalalignment','right','fontsize',8)
    end
    ylabel(unit,'verticalalignment','baseline','position',[7,ylim1(1)+(ylim1(2)-ylim1(1))/2])
    
% --- add Info to plot
    y=0.1;
    subplot(4,4,1)
    text(0.5,y,'Interpolated topoplot','horizontalalignment','center')
    axis off
    
    subplot(4,4,3);text(0.5,y,[cell2mat(statdata.test),' per subregions'],'horizontalalignment','center')
    axis off
    
    subplot(4,4,2)
    textThis = sprintf('Statistics for difference in "%s" between conditions %s and %s for %i subjects',regexprep(biomarker,'_',' '),cond1,cond2,size(c1,2));
    % nbt_split_title([0.5 0.5],textThis,90,11);
    title(textThis);
    text(0.5,y,'Actual channels','horizontalalignment','center')
    axis off
    
    subplot(4,4,4);text(0.5,y,['Errorbars and ',cell2mat(statdata.test),' per subregion'],'horizontalalignment','center')
    axis off
    
end

