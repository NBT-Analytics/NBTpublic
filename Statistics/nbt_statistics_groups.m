function[p_biomarkers,p_regions]=nbt_statistics_groups(varargin)

%usage:  nbt_statistics_groups(directory1,directory2,biomarker,statistic,plotting)

% Inputs:
% directory1 = path to directoy with first group of NBT files
% directory1 = path to directoy with second group of NBT files
% biomarker = name of biomarker, as it is written in the analysis file
% statistic = 'mean' (default) or 'median'
% plotting = 0 (default) or 1. If plotting =1, a pdf will be generated with a plot of the statistics

%  for example:
%  nbt_statistics_groups('C:\NBTfiles\control','C:\NBTfiles\condition1','amplitude_3_7_Hz.Channels','median',1)

% This function visualizes statistics of the biomarker within and between the
% two groups of NBT Signals in directory1 and directory2

%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2010), see NBT website for current email address
%------------------------------------------------------------------------------------

% Copyright (C) 2008  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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

%% assign fields

fontsize=8;
P=varargin;
nargs=length(P);

if (nargs<1 | isempty(P{1})) disp('Select folder with first group of NBT files to analyze');[path]=uigetdir([],'Select folder with first group of NBT files to analyze'); else path = P{1}; end;
if (nargs<2 | isempty(P{2})) disp('Select folder with second group of NBT files to analyze');[path1]=uigetdir(path,'Select folder with second group of NBT files to analyze'); else path1 = P{2}; end;

if (nargs<3 | isempty(P{3}))
    % get biomarker
    d=dir(path);
    for i=1:length(d)
        if ~isempty(findstr('analysis',d(i).name))
            [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path,'/', d(i).name]);
            break
        end
    end
    [selection,ok]=listdlg('liststring',biomarker_objects, 'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select biomarker object');
    biomarker_object=biomarker_objects{selection};
    [selection1,ok]=listdlg('liststring',biomarkers{selection},'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select biomarker');
    biomarker=strcat(biomarker_object,'.',biomarkers{selection}(selection1));
    biomarker=inputdlg('edit biomarker name?','',1,biomarker);
    biomarker=cell2mat(biomarker);
else biomarker = P{3};
end

if (nargs<3 | isempty(P{4}))
    stat={'mean','median'};
    [selection,ok]=listdlg('liststring',stat, 'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select statistic');
    statistic=stat{selection};
else statistic= P{4}; end;

if (nargs<5 | isempty(P{5})) plotting=0; else plotting = P{5}; end;

if strcmp(statistic,'mean')
    statistic=@nanmean;
    statfunc = @ttest2;
    statfuncname='ttest2';
    statname='mean';
else
    statistic=@nanmedian;
    statfunc = @ranksum;
    statfuncname='ranksum';
    statname='median';
end

c1_regions=[];
c2_regions=[];

SignalInfo=nbt_getInfoObject(path,'Signal'); % get one Info file for locations channels, in case of EEG data
disp(['Computing statistics for ',biomarker])

disp(' ')
disp('Command window code:')
disp(['nbt_statistics_groups(',char(39),path,char(39),',',char(39),path1,char(39),',',char(39),biomarker,char(39),',',char(39),statname,char(39),',',num2str(plotting),');'])
disp(' ')

%% get biomarkers from analysis files

c1=nbt_load_analysis(path,[],biomarker,@nbt_get_biomarker,[],[],[]);
c2=nbt_load_analysis(path1,[],biomarker,@nbt_get_biomarker,[],[],[]);
c1=c1;
c2=c2;

% create grand averages:

meanc1=statistic(c1,2); %mean / median per biomarker group 1
meanc2=statistic(c2,2); %mean / median per biomarker group 2
Diffc2c1=meanc2-meanc1;

%  c1 contains the biomarker from the subjects from group 1: subjects are
%  in columns, biomarkers are in rows
%  c2 contains the same data, for group 2.

number_of_biomarkers=size(c1,1);

%% test per biomarker for difference between groups

for i=1:number_of_biomarkers
    if strcmp(statfuncname,'ttest2')
        [h(i),p_biomarkers(i),ci(i,:)]=statfunc(c1(i,:),c2(i,:));
    end
    if strcmp(statfuncname,'ranksum')
        p_biomarkers(i)=statfunc(c1(i,:),c2(i,:));
    end
end

%%  In case of 129-channel EEG, create differences per region and test per region

if (isfield(SignalInfo.Interface,'EEG') && number_of_biomarkers==129)
    
    for i=1:size(c1,2) % nr subjects
        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
    end
    for i=1:size(c2,2) % nr subjects
        c2_regions(:,i) = nbt_get_regions(c2(:,i),[],SignalInfo);
    end
    %  c1_regions contains the biomarker averaged within the six subregions for group 1:  subjects are
    %  in columns, subregions are in rows
    
    % test per region
    for i=1:size(c1_regions,1)
        if strcmp(statfuncname,'ttest2')
            [h(i),p_regions(i),ci(i,:)]=statfunc(c1_regions(i,:),c2_regions(i,:));
        end
        if strcmp(statfuncname,'ranksum')
            p_regions(i)=statfunc(c1_regions(i,:),c2_regions(i,:));
        end
    end
end

%% in case of 129-channel EEG data, here the plotting starts:

if isfield(SignalInfo.Interface,'EEG') && number_of_biomarkers==129
    
    %----------        get figure handle
    done=0;
    figHandles = findobj('Type','figure');
    for i=1:length(figHandles)
        if strcmp(get(figHandles(i),'Tag'),'stat_groups')
            figure(figHandles(i))
            done=1;
        end
    end
    if ~done
        figure()
        set(gcf,'Tag','stat_groups');
    end
    set(gcf,'name','NBT: group statistics EEG','numbertitle','off');
    clf
    set(gcf,'position',[1          31       1280      920]) %1280
    
    %  get means/medians per group
    mean_c1_regions=statistic(c1_regions,2);% mean / median per region group 1
    mean_c2_regions=statistic(c2_regions,2);% mean / median per region group 2
    
    % ---for color scale in following plots
    vmax=max([meanc1,meanc2]);
    vmin=min([meanc1,meanc2]);
    rmax=max([mean_c1_regions,mean_c2_regions]);
    rmin=min([mean_c1_regions,mean_c2_regions]);
    cmax = max([vmax, rmax]);
    cmin = min([vmin, rmin]);
    
    %% plot grand average group 1 per channel:
    
    xa=-2;
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
    
    %% plot grand average group 1 subregions
    subplot(4,4,7)
    nbt_plot_subregions(mean_c1_regions,1,cmin,cmax)
    colorbar('westoutside')
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    
    %%   plot grand average group 2 per channel:
    
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
    
    %% plot grand average group2 subregions
    subplot(4,4,11)
    nbt_plot_subregions(mean_c2_regions,1,cmin,cmax)
    colorbar('westoutside')
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    
    %% Plot log10(P-Values) to trick colour bar
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
    
    %% Plot difference group 1 vs group 2 per channel
    subplot(4,4,13)
    topoplot(statistic(Diffc2c1,2),SignalInfo.Interface.EEG.chanlocs,'headrad','rim');
    colorbar('westoutside')
    textThis = sprintf('Grand average for group 2 minus group 1');
    nbt_split_text(xa,0.15,textThis,20,fontsize);
    axis off
    set(gca,'fontsize',fontsize)
    
    %% plot p-values per subregion
    
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
    %
    %% Plot group 1 errorbars per region
    region{1}='frontal';
    region{2}='left temporal';
    region{3}='central';
    region{4}='right temporal';
    region{5}='parietal';
    region{6}='occipital';
    
    if strcmp(statfuncname,'ttest')
        [h,p,C]=statfunc(c1_regions');
    else
        for i=1:size(c1_regions,1)
            C(:,i)=bootci(1000,@median,c1_regions(i,:));
        end
    end
    diff=statistic(C);
    subplot(4,4,8)
    errorbar(1:6,diff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff,'r.','Markersize',10)
    plot(1.2:6.2,c1_regions','.k')
    ylim1=get(gca,'ylim');
    ylabel('\muV','verticalalignment','baseline','position',[7,ylim1(1)+(ylim1(2)-ylim1(1))/2])
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)
    
    %%  Plot group 2 errorbars per region
    if strcmp(statfuncname,'ttest')
        [h,p,C]=statfunc(c2_regions');
    else
        for i=1:size(c2_regions,1)
            C(:,i)=bootci(1000,@median,c2_regions(i,:));
        end
    end
    diff=statistic(C);
    subplot(4,4,12)
    errorbar(1:6,diff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff,'r.','Markersize',10)
    plot(1.2:6.2,c2_regions','.k')
    ylim2=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)
    
    %% set axis equal for two groups
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
    
    %% test for difference: group 2 - group 1, plot errorbars per region
    
    if strcmp(statfuncname,'ttest2')
        size(c1_regions)
        size(c2_regions)
        [h,p,C]=statfunc(c1_regions',c2_regions');
    else
        for i=1:size(diff_regions,1)
            C(:,i)=bootci(1000,@median_diff,[c1_regions(i,:);c2_regions(i,:)]);
        end
    end
    
    diff=statistic(C);
    subplot(4,4,16)
    errorbar(1:6,diff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff,'r.','Markersize',10)
    %     plot(1.2:6.2,c2_regions' - c1_regions','.k')
    ylim1=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)
    ax=get(gca,'ylim');
    for i=1:6
        text(i,ax(1),region{i},'rotation',45,'horizontalalignment','right','fontsize',8)
    end
    
    %%                            add Info to plot
    y=0.1;
    subplot(4,4,1)
    text(0.5,y,'Interpolated topoplot','horizontalalignment','center')
    axis off
    
    subplot(4,4,3);text(0.5,y,[statname,' per subregions'],'horizontalalignment','center')
    axis off
    
    subplot(4,4,2)
    textThis = sprintf('Statistics for difference in "%s" between group 1 and group 2',regexprep(biomarker,'_',' '));
    % nbt_split_title([0.5 0.5],textThis,90,11);
    title(textThis);
    text(0.5,y,'Actual channels','horizontalalignment','center')
    axis off
    
    subplot(4,4,4);text(0.5,y,['Errorbars and ',statname,' per subregion'],'horizontalalignment','center')
    axis off
    
    %%                   make PDF
    if plotting==1
        paperp=[0 0 30 25];
        set(gcf,'paperunits','centimeters','papersize',[30 25],'paperposition',paperp)
        print(gcf,'-dpdf',[path,'/',biomarker,'difference between groups','.pdf'])
    end   
end

%%    Also for NON-EEG data: make plot for each biomarker with errorbars and individual data points

%        get figure handle
done=0;
figHandles = findobj('Type','figure');
for i=1:length(figHandles)
    if strcmp(get(figHandles(i),'Tag'),'stat_groups_er')
        figure(figHandles(i))
        done=1;
    end
end
if ~done
    figure()
    set(gcf,'Tag','stat_groups_er');
end
clf
set(gcf,'name','NBT: groups statistics','numbertitle','off');
set(gcf,'position',[214          51        1291         438])

%--- assign values:
pointsize=15;

% compute confidence intervals:
if strcmp(statfuncname,'ttest2')
    for i=1:size(c1,1)
        [h(i),p(i),C(:,i)]=statfunc(c2(i,:),c1(i,:));
    end
else
    for i=1:size(c1,1)
        p(i)=statfunc(c2(i,:),c1(i,:));
        C(:,i)=bootci(1000,@median_diff,c2(i,:),c1(i,:));
    end
end
%--- plot errorbars and means/medians
s=Diffc2c1;
in1=find(s>0);
in2=find(s<0);
vec1=zeros(1,length(s));
vec1(in1)=(C(2,in1)-C(1,in1))/2;
vec2=zeros(1,length(s));
vec2(in2)=(C(2,in2)-C(1,in2))/2;
%     error bars on both sides of mean/median:
hold on
ha= errorbar(1:number_of_biomarkers,statistic(C),vec2,vec1,'linestyle','none', ...
    'markeredgecolor','red','marker','none','markersize',10);
B= bar(statistic(C));
%     error bars only on top of bar:
ha1= errorbar(1:number_of_biomarkers,statistic(C),(C(2,:)-C(1,:))/2,'linestyle','none', ...
    'markeredgecolor','red','marker','none','markersize',10);
set(ha1,'visible','off')

%  get significant p-values
Level=0.05;
ind=find(p<Level);
M=plot(1:number_of_biomarkers,statistic(C),'r.','Markersize',pointsize);
S=plot(ind,statistic(C(:,ind)),'g.','Markersize',pointsize);
if isempty(ind)
    S=plot(1,statistic(C(:,1)),'.g','visible','off','Markersize',pointsize);
end
hold off

%%%%%%%%%%%code from matlab homepage to change size of bars:
hb = get(ha,'children');
Xdata = get(hb(2),'Xdata');
temp = 4:3:length(Xdata);
temp(3:3:end) = [];
% xleft and xright contain the indices of the left and right
% endpoints of the horizontal lines
xleft = temp; xright = temp+1;
diff=Xdata(xright)-Xdata(xleft);
toomuch=diff-0.25;
% Decreas line length by
Xdata(xleft) = Xdata(xleft) + toomuch/2;
Xdata(xright) = Xdata(xright) - toomuch/2;
set(hb(2),'Xdata',Xdata)

hb = get(ha1,'children');
Xdata = get(hb(2),'Xdata');
temp = 4:3:length(Xdata);
temp(3:3:end) = [];
% xleft and xright contain the indices of the left and right
% endpoints of the horizontal lines
xleft = temp; xright = temp+1;
diff=Xdata(xright)-Xdata(xleft);
toomuch=diff-0.25;
% Decreas line length by
Xdata(xleft) = Xdata(xleft) + toomuch/2;
Xdata(xright) = Xdata(xright) - toomuch/2;
set(hb(2),'Xdata',Xdata)

% axis & labels
ax=get(gca,'ylim');
axis tight
ylim(ax)
ax2=get(gca,'ylim');
xlabel('Biomarker number')
ylabel(['Errorbars of ',statname,' for the difference between groups'])
title(biomarker,'interpreter','none')
legend([M,S],'Not significant','Significant')

%%  buttons

button1=uicontrol('Units', 'normalized', ...
    'callback',{@set_bar} ,...
    'string','click here to show/hide bars ',...
    'position',[0.4 0 0.3 0.05],'Visible','on');

sl1=uicontrol('Units', 'normalized','style','slider','min',min(p), 'max' ,max(p) , ...
    'sliderstep',[(max(p)-min(p))/20,(max(p)-min(p))/10],'Value',(max(p)-min(p))/2, 'callback',{@set_p},...
    'position',[0 0 0.3 0.05],'Visible','on',...
    'string',[num2str(max(p)-min(p))/2]);
TE=text( -0.1561,   -0.0498  ,['slide to change significance level: ',num2str((max(p)-min(p))/2)],'units','normalized');

    function[]=set_bar(d1,d2,x,h)
        if strcmp(get(B,'visible'),'on')
            set(B,'visible','off')
            set(ha,'visible','off')
            set(ha1,'visible','on')
        else
            set(B,'visible','on')
            set(ha,'visible','on')
            set(ha1,'visible','off')
        end
    end

    function[]=set_p(d1,d2,x,h)
        Level=get(sl1,'value');
        ind=find(p<Level);
        set(M,'visible','off')
        set(S,'visible','off')
        hold on
        M=plot(1:number_of_biomarkers,statistic(C),'r.','Markersize',pointsize);
        S=plot(ind,statistic(C(:,ind)),'g.','Markersize',pointsize);
        hold off
        set(TE,'visible','off')
        TE=text( -0.1561,   -0.0498  ,['slide to change significance level: ',num2str(get(sl1,'value'))],'units','normalized');
    end

    function[d]=median_diff(M,N)
        m1=nanmedian(M);
        m2=nanmedian(N);
        d=m2-m1;
    end

end