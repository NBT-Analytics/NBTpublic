% Compute and visualize statistics of a biomarker within a group of
% NBT signals.
%
% Usage: nbt_statistics_group(directory,biomarker,statistic,plotting)
%
% Inputs:
% directory = path to directoy with NBT files
% biomarker = name of biomarker, as it is written in the analysis file
% statistic = 'mean' (default) or 'median'
% plotting = 0 (default) or 1. If plotting =1, a pdf will be generated with a plot of the statistics
%
% For example:
% nbt_statistics_group('C:\NBT','amplitude_1_4_Hz.Channels','median',1)
%
% References:
% 
% See also: 
% nbt_statistics_conditions, nbt_statistics_groups

%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2010), see NBT website for current email
% address
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
% ---------------------------------------------------------------------------------------
function nbt_statistics_group(varargin)

%% assign fields

fontsize=8;
P=varargin;
nargs=length(P);

if (nargs<1 | isempty(P{1}))[path]=uigetdir([],'select folder with NBT Signals'); else path = P{1}; end;


if (nargs<2 | isempty(P{2}))
    % get biomarker
    
    if(isdir(path))
    d=dir(path);
    %--- for files copied from a mac
    startindex = 0;
    for i = 1:length(d)
        if  strcmp(d(i).name(1),'.') || strcmp(d(i).name(1:2),'..') || strcmp(d(i).name(1:2),'._')
            startindex = i+1;
        end
    end
    %---
    for i=startindex:length(d)
        if ~isempty(findstr('analysis',d(i).name))
            [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path,'/', d(i).name]);
            break
        end
    end
    
    else
        [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path(1:end-4) '_analysis.mat']);
    end
    
    
    [selection,ok]=listdlg('liststring',biomarker_objects, 'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select biomarker object');
    biomarker_object=biomarker_objects{selection};
    [selection1,ok]=listdlg('liststring',biomarkers{selection},'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select biomarker');
    biomarker=strcat(biomarker_object,'.',biomarkers{selection}(selection1));
    biomarker=inputdlg('edit biomarker name?','',1,biomarker);
    biomarker=cell2mat(biomarker);
else biomarker = P{2};
end

if (nargs<3 | isempty(P{3}))
%     stat={'mean','median', 'plot'};
 stat={'mean','median'};
    [selection,ok]=listdlg('liststring',stat, 'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select statistic');
    statistic=stat{selection};
else statistic= P{3}; end;

if (nargs<4 | isempty(P{4})) plotting=1; else plotting = P{4}; end;

c1_regions=[];
if(isdir(path))
    SignalInfo=nbt_getInfoObject(path,'Signal'); % get one Info file for locations channels, in case of EEG data
else
    SignalInfo=load([path(1:end-4) '_info.mat']);
    flds = fieldnames(SignalInfo);
    if length(flds) == 1
        SignalInfo = eval(['SignalInfo.',flds{1}]);
    else
        [selfld,ok]=listdlg('liststring',flds, 'SelectionMode','single', 'ListSize',[250 300],'PromptString','Select NBT Info Object');        
        SignalInfo = eval(['SignalInfo.',flds{selfld}]);        
    end        
end
disp(' ')
disp('Command window code:')
disp(['nbt_statistics_group(',char(39),path,char(39),',',char(39),biomarker,char(39),',',char(39),statistic,char(39),',',num2str(plotting),');'])
disp(' ')

if strcmp(statistic,'mean')
    statistic=@nanmean;
    statfunc = @ttest;
    statfuncname='ttest';
    statname='mean';
elseif strcmp(statistic,'median')
    statistic=@nanmedian;
    statfunc = @signrank;
    statfuncname='signrank';
    statname='median';
% else %i.e. plot so we will plot directly
%     plot(nbt_get_biomarker([path(1:end-4) '_analysis.mat'],biomarker,[],1));
%     return
end

%% get biomarkers from analysis files
if(isdir(path))
    [c1,s1,p1,unit]=nbt_load_analysis(path,[],biomarker,@nbt_get_biomarker,[],[],[]);
else
    [c1,unit] = nbt_get_biomarker([path(1:end-4) '_analysis.mat'],biomarker,[]);
end

% c1=c1';
number_of_biomarkers=size(c1,1);
number_of_subjects=size(c1,2);

%  c1 contains the biomarkers, subjects are
%  in columns,biomarkers (for example channels) are in rows

% test per biomarker
for i=1:number_of_biomarkers
    if strcmp(statfuncname,'ttest')
        [h(i),p_biomarkers(i),ci(i,:)]=statfunc(c1(i,:));
    end
    if strcmp(statfuncname,'signrank')
        p_biomarkers(i)=statfunc(c1(i,:));
    end
end

%% test per region in case of 129-channel EEG data

if (isfield(SignalInfo.Interface,'EEG') && number_of_biomarkers==129) 
    
    for i=1:number_of_subjects 
        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
    end
    %  c1_regions contains the biomarker averaged within the six subregions:  subjects are
    %  in columns, subregions are in rows
    
    % test per region
    for i=1:size(c1_regions,1)
        if strcmp(statfuncname,'ttest')
            [h(i),p_regions(i),ci(i,:)]=statfunc(c1_regions(i,:));
        end
        if strcmp(statfuncname,'signrank')
            p_regions(i)=statfunc(c1_regions(i,:));
        end
    end
end


    
    %%        get figure handle
    done=0;
    figHandles = findobj('Type','figure');
    for i=1:length(figHandles)
        if strcmp(get(figHandles(i),'Tag'),'stat_group')
            figure(figHandles(i))
            done=1;
        end
    end
    if ~done
        figure()
        set(gcf,'Tag','stat_group');
    end
    set(gcf,'name','NBT: group statistics EEG','numbertitle','off');
    clf   
    set(gcf,'position',[215         546        1280         431])
    
    %% create grand averages:
    
    meanc1=statistic(c1,2); %mean / median per biomarker
    vmax=max(meanc1);
    vmin=min(meanc1);
    
    mean_c1_regions=statistic(c1_regions,2); %mean / median per region
    rmax=max(mean_c1_regions);
    rmin=min(mean_c1_regions);
    
    cmax = max([vmax, rmax]);
    cmin = min([vmin, rmin]);
    
    %% plot grand average per channel:
    xa=-2;
    
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
    
    %% in case of 129-channel EEG data, we also plot the sub-regions:

if isfield(SignalInfo.Interface,'EEG') && number_of_biomarkers==129 
    %% plot grand average subregions
    subplot(2,4,7)
    nbt_plot_subregions(mean_c1_regions,1,cmin,cmax)
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    
    %
    %% Plot errorbars per region
    region{1}='frontal';
    region{2}='left temporal';
    region{3}='central';
    region{4}='right temporal';
    region{5}='parietal';
    region{6}='occipital';
    if number_of_subjects == 1
        subplot(2,4,8)
%         errorbar(1:6,diff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
%             'markeredgecolor','red','marker','none','markersize',10)
%         hold on
%         plot(1:6,diff,'r.','Markersize',10)
        plot(1.2:6.2,c1_regions','.k')
        ylim1=get(gca,'ylim');
        ylabel(unit,'verticalalignment','baseline','position',[7,ylim1(1)+(ylim1(2)-ylim1(1))/2])
        set(gca,'xtick',[]);
        hold off
        for reg= 1:length(region)
            text(reg, ylim1(1),region{reg},'verticalalignment','base','fontsize',8,'rotation',-30,'fontweight','bold');
        end
        
        set(gca,'xlim',[0.5 6.5])
        set(gca,'fontsize',fontsize)
        
            
        
    else
        
    if strcmp(statfuncname,'ttest')
        [h,p,C]=statfunc(c1_regions');
    else
        for i=1:size(c1_regions,1)
            C(:,i)=bootci(1000,@nanmedian,c1_regions(i,:));
        end
    end
    diff=mean(C);
    subplot(2,4,8)
    errorbar(1:6,diff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff,'r.','Markersize',10)
    plot(1.2:6.2,c1_regions','.k')
    ylim1=get(gca,'ylim');
    ylabel(unit,'verticalalignment','baseline','position',[7,ylim1(1)+(ylim1(2)-ylim1(1))/2])
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)
    end
end
    
    %%                            add Info to plot
    y=0.1;
    subplot(2,4,1)
    text(0.5,y,'Interpolated topoplot','horizontalalignment','center','fontweight','bold')
    axis off
    
    subplot(2,4,3);text(0.5,y,[statname,' per subregions'],'horizontalalignment','center','fontweight','bold')
    axis off
    
    subplot(2,4,2)
    text(0.5,y,'Actual channels','horizontalalignment','center','fontweight','bold')
    axis off
    
    subplot(2,4,4);text(0.5,y,[statname,' per subregions'],'horizontalalignment','center','fontweight','bold')
    axis off
    
    subplot(2,4,2)
    title(['Statistics for ',regexprep(biomarker,'_',' ')],'interpreter','none','fontweight','bold');
    
    %%                   make PDF
    
%     if plotting
%         paperp=[0 0 30 15];
%         set(gcf,'paperunits','centimeters','papersize',[30 15],'paperposition',paperp)
%         print(gcf,'-dpdf',[path,'/',biomarker,'.pdf'])
%     end



%%  Also for NON-EEG data: make plot for each biomarker with errorbars and individual data points

if(size(c1,2) > 1)
%        get figure handle
done=0;
figHandles = findobj('Type','figure');
for i=1:length(figHandles)
    if strcmp(get(figHandles(i),'Tag'),'stat_group_er')
        figure(figHandles(i))
        done=1;
    end
end
if ~done
    figure()
    set(gcf,'Tag','stat_group_er');
end
clf
set(gcf,'name','NBT: group statistics','numbertitle','off');
set(gcf,'position',[214          51        1291         438])

%--- assign values:
pointsize=15;
nr_ch=size(c1,1);

% --- compute confidence intervals
if strcmp(statfuncname,'ttest')
    [h,p,C]=statfunc(c1');
else
    for i=1:size(c1,1)
        p(i)=statfunc(c1(i,:));
        C(:,i)=bootci(1000,@nanmedian,c1(i,:));
    end
end

%--- plot errorbars and means/medians
s=statistic(C);
in1=find(s>0);
in2=find(s<0);
vec1=zeros(1,length(s));
vec1(in1)=(C(2,in1)-C(1,in1))/2;
vec2=zeros(1,length(s));
vec2(in2)=(C(2,in2)-C(1,in2))/2;
%     error bar on both sides of mean/median:
hold on
ha= errorbar(1:nr_ch,statistic(C),vec2,vec1,'linestyle','none', ...
    'markeredgecolor','red','marker','none','markersize',10);
B= bar(statistic(C));
%     error bar only on top of bar:
ha1= errorbar(1:nr_ch,statistic(C),(C(2,:)-C(1,:))/2,'linestyle','none', ...
    'markeredgecolor','red','marker','none','markersize',10);
set(ha1,'visible','off')

%   plot means/medians:
M=plot(1:nr_ch,statistic(C),'r.','Markersize',pointsize);
set(M,'visible','off')
hold off

%%%%%%%%%%%   code from matlab homepage to change size of bars:
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

%% plot individual data points
ax1=get(gca,'ylim');
hold on
P= plot([1:nr_ch]+0.2,c1,'.k') ;
hold off

%--- labels
ax=get(gca,'ylim');
axis tight
ylim(ax)
ax2=get(gca,'ylim');
xlabel('Biomarker number')
ylabel(['Errorbars of ',statname,' for ',regexprep(biomarker,'_',' ')],'interpreter','none')
title(regexprep(biomarker,'_',' '),'interpreter','none')

%%  buttons

button1=uicontrol('Units', 'normalized', ...
    'callback',{@set_bar} ,...
    'string','click here to show/hide bars ',...
    'position',[0 0    0.3000    0.0500],'Visible','on');

button2=uicontrol('Units', 'normalized', ...
    'callback',{@set_points} ,...
    'string','click here to show/hide data points ',...
    'position',[0.75 0 0.3 0.05],'Visible','on');

end
    function[]=set_bar(d1,d2,x,h)
        if strcmp(get(B,'visible'),'on')
            set(B,'visible','off')
            set(ha,'visible','off')
            set(ha1,'visible','on')
            set(M,'visible','on')
        else
            set(B,'visible','on')
            set(ha,'visible','on')
            set(ha1,'visible','off')
            set(M,'visible','off')
        end
    end

    function[]=set_points(d1,d2,x,h)
        if strcmp(get(P,'visible'),'on')
            set(P,'visible','off')
            set(gca,'ylim',ax1);
        else
            set(P,'visible','on')
            set(gca,'ylim',ax2);
        end
    end

end
