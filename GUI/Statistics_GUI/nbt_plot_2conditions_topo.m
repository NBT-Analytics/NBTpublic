%  nbt_plot_2conditions_topo - topoplot for statistics with two groups or conditions
%
% Usage:
% nbt_plot_2conditions_topo(Group1,Group2,chanloc,s,unit,biomarker,regions)
%
% Inputs:
%   Group1,
%   Group2,
%   chanloc,
%   s,
%   unit,
%   biomarker,
%   regions
%
% Outputs:
%
%
% Example:
%
%
% References:
%
% See also:
%  nbt_plot_EEG_channels, nbt_plot_stat

%------------------------------------------------------------------------------------
% Originally created by Rick Jansen, see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
% modified by Giuseppina Schiavone (2012)
%
% Copyright (C) 2011 Rick Jansen  (Neuronal Oscillations and Cognition group,
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
% --------------


function nbt_plot_2conditions_topo(Group1,Group2,chanloc,s,unit,biomarker,regions)

condition1 = Group1.selection.group_name;
condition2 = Group2.selection.group_name;

meanc1=s.meanc1; %mean / median per channel condition 1
meanc2=s.meanc2; %mean / median per channel condition 2
p = s.p;
c1 = s.c1;
c2 = s.c2;
Cdiff = s.C;
if size(c1,2) == size(c2,2)
    diffC2C1 = c2-c1;
else
    diffC2C1 = [];
end
diffC2C1_2 = meanc2-meanc1;
statistic=s.statistic;
statfunc = s.statfunc;
statfuncname={s.statfuncname};
fontsize = 10;
if isempty(regions)
    
    fontsize = 10;
    fig1 = figure('name',['NBT: Statistics (Channels) for ',regexprep(biomarker,'_',' ')],...
        'NumberTitle','off','position',[10          80       1500      500]); %128
    fig1=nbt_movegui(fig1);
    
    %plot control buttons
    uicontrol(fig1, 'Style', 'pushbutton', 'string', 'Pop out', 'position', [20 400 60 20],'callback',@plot_interpolatedFigure);
    uicontrol(fig1, 'Style', 'pushbutton', 'string', 'Print', 'position', [20 450 60 20], 'callback', @print_topo);
    uicontrol(fig1, 'Style', 'pushbutton', 'string', 'Pop out','position',[300 20 60 20], 'callback', @plot_diffTopo);
    uicontrol(fig1, 'Style', 'pushbutton', 'string', 'Pop out', 'position',[600 20 60 20],'callback', @plot_pTopo);
    
    % ---for color scale in following plots
    vmax=max([meanc1,meanc2]);
    vmin=min([meanc1,meanc2]);
    cmax = max(vmax);
    cmin = min(vmin);
    cmin = 0; %change here for lower limit
    
    xa=-2.5;
    ya = 0.25;
    maxline = 20;
    
    %---plot grand average condition 1 per channel(Interpolated Plot)
    subplot(4,3,4)
    plot_interpolatedTopo(1);
    cbfreeze
    freezeColors
    drawnow
    
    %---plot grand average condition 2 per channel(Interpolated Plot)
    subplot(4,3,7)
    plot_interpolatedTopo(2);
    cbfreeze
    freezeColors
    drawnow
    
    %---plot grand average condition 1 per channel(Actual Channels)
    subplot(4,3,5)
    calctext = text(1,1,'Calculating...');
    %nbt_plot_EEG_channels(meanc1,cmin,cmax,chanloc,nbt_redwhite,unit);
    nbt_plot_EEG_channels(meanc1,cmin,cmax,chanloc,Reds5,unit);
    
    %---plot grand average condition 2 per channel(Actual Channels)
    subplot(4,3,8)
    calctext = text(1,1,'Calculating...');
    %nbt_plot_EEG_channels(meanc2,cmin,cmax,chanloc,nbt_redwhite,unit);
    nbt_plot_EEG_channels(meanc2,cmin,cmax,chanloc,Reds5,unit);
    
    %---plot grand average difference between conditions or difference between group means (Interpolated Plot)
    subplot(4,3,10)
    plot_interpolatedTopo(3)
    freezeColors
    cbfreeze
    drawnow
 
    %---plot P-values for the test (log scaled colorbar)
    %minPValue = -2;% Plot log10(P-Values) to trick colour bar -
    %maxPValue = -0.5;
    % red white blue color scale
    minPValue = log10(0.0005);
    maxPValue = -log10(0.0005);
    pLog = log10(p); % to make it log scaled
    
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'signrank')
        pLog = sign(statistic(diffC2C1,2))'.*pLog;
    else
        pLog = sign(statistic(diffC2C1_2,2))'.*pLog;
    end
    pLog = -1*pLog;
    pLog( pLog<minPValue) = minPValue;
    pLog(pLog> maxPValue) = maxPValue;
     
    subplot(4,3,11)
    plot_pTopo()
    drawnow
    cbfreeze
    
    
    %   nbt_plot_EEG_channels(p,minPValue,maxPValue,chanloc,CoolWarm,'P-values');
    
    %     a=get(gca,'xlim');
    %     b=get(gca,'ylim');
    %     text(a(1),b(1)-(b(2)-b(1))/10,'P-values','horizontalalignment','right')
    %--- plot condition 1 errorbars per channels
    n_cnl = size(c1,1);
    subplot(4,3,6)
    calctext = text(1,1,'Calculating...');
    drawnow
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'ttest2')
        [h,p,C]=ttest(c1');
    else
        for i=1:size(c1,1)
            try
                C(:,i)=bootci(1000,@nanmedian,c1(i,:));
            catch
            end
            
        end
    end
    meanc1 = statistic(c1,2);
    errorbar(1:n_cnl,meanc1,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:n_cnl,meanc1,'r.','Markersize',10)
    %     plot(1.2:n_cnl+0.2,c1','.k')
    ylim1=get(gca,'ylim');
    ylabel(unit)
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 n_cnl+0.5])
    set(gca,'fontsize',fontsize)
    drawnow
    %--- plot condition 2 errorbars per channels
    subplot(4,3,9)
    text(1,1, 'Calculating...')
    drawnow
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'ttest2')
        [h,p,C]=ttest(c2');
    else
        for i=1:size(c2,1)
            try
                C(:,i)=bootci(1000,@nanmedian,c2(i,:));
            catch
            end
        end
    end
    
    meanc2 = statistic(c2,2);
    errorbar(1:n_cnl,meanc2,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:n_cnl,meanc2,'r.','Markersize',10)
    %     plot(1.2:n_cnl+0.2,c2','.k')
    ylim2=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 n_cnl+0.5])
    set(gca,'fontsize',fontsize)
    ylabel(unit)
    %--- set axis equal for two conditions
    maxylim=max(ylim1(2),ylim2(2));
    minylim=max(ylim1(1),ylim2(1));
    set(gca,'ylim',[minylim,maxylim])
    xlabel('Channels')
    subplot(4,3,6)
    set(gca,'ylim',[minylim,maxylim])
    xlabel('Channels')
    drawnow
    %--- test for difference: condition 2 - condition 1, plot errorbars per
    %channels
    C = Cdiff';
    meanDiff = meanc2 - meanc1;
    subplot(4,3,12)
    try
        errorbar(1:n_cnl,meanDiff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
            'markeredgecolor','red','marker','none','markersize',10)
    catch
    end
    hold on
    plot(1:n_cnl,meanDiff,'r.','Markersize',10)
    ylim1=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 n_cnl+0.5])
    set(gca,'fontsize',fontsize)
    ax=get(gca,'ylim');
    xlabel('Channels')
    ylabel(unit)
    drawnow
    %--- tiles and info
    %   Interpolated topoplot
    y=0.1;
    subplot(4,3,1)
    text(0.5,y,'Interpolated topoplot','horizontalalignment','center')
    axis off
    %   Title
    subplot(4,3,2)
    textThis = sprintf('Statistics for difference in "%s" between %s (n = %i) and %s (n = %i) ',regexprep(biomarker,'_',' '),...
        regexprep(condition2,'_',' '),size(c2,2),regexprep(condition1,'_',' '),size(c1,2));
    nbt_split_title([0.2 1],textThis,200,11);
    %     title(textThis,'fontweight','bold');
    %   Actual Channels
    text(0.5,y,'Actual channels','horizontalalignment','center')
    axis off
    %   Error Bar
    subplot(4,3,3);text(0.5,y,['Errorbars and ',statfuncname,' per channels'],'horizontalalignment','center')
    axis off
    %--- Zoom on statistics
    s.test = statfuncname;
    
         if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'signrank')
             nbt_plot_stat(diffC2C1,s,biomarker,condition2,condition1);
         else
             nbt_plot_stat(diffC2C1_2,s,biomarker,condition2,condition1);
         end
    
else % when Regions are specified
    fontsize = 10;
    fig2 = figure('name',['NBT: Statistics (Regions) for ',regexprep(biomarker,'_',' ')],'NumberTitle','off',...
        'position',[10          80       1500      500]); %128
    fig2=nbt_movegui(fig2);
    
    % ---for color scale in following plots
    vmax=max([meanc1,meanc2]);
    vmin=min([meanc1,meanc2]);
    cmax = max(vmax);
    cmin = min(vmin);
    
    xa=-5;
    ya = 0.25;
    maxline = 20;
    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
    coolWarm = coolWarm.coolWarm;
    colormap(coolWarm);
    

    
    %---plot grand average condition 1 per regions
    subplot(4,2,3)
    chns_for_topo = nan(size(chanloc));
    for l = 1:length(regions)
        region{l} = regexprep(regions(l).reg.name,'_',' ');
        chans_reg{l} = regions(l).reg.channel_nr;
        chns_for_topo(regions(l).reg.channel_nr) = meanc1(l);
    end
    
    %     nbt_plot_EEG_channels(chns_for_topo,cmin,cmax,chanloc)
    standard = checkregions(chans_reg);
    if standard == 1
        nbt_plot_subregions(meanc1,1,cmin,cmax,chans_reg) % improve his function for more regions
    else
        nbt_plot_EEG_channels(chns_for_topo,cmin,cmax,chanloc)
    end
    axis square
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    drawnow
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'signrank')
        textThis = sprintf('Grand average for condition: %s (n = %i)',condition1,size(c1,2));
    else
        textThis = sprintf('Grand average for group %s (n = %i)',condition1,size(c1,2));
    end
    nbt_split_text(xa,ya,textThis,maxline,fontsize);
    set(gca,'fontsize',fontsize)
    
    
    %---plot grand average condition 2 per regions
    subplot(4,2,5)
    chns_for_topo = nan(size(chanloc));
    for l = 1:length(regions)
        region{l} = regexprep(regions(l).reg.name,'_',' ');
        chans_reg{l} = regions(l).reg.channel_nr;
        chns_for_topo(regions(l).reg.channel_nr) = meanc2(l);
    end
    %     nbt_plot_EEG_channels(chns_for_topo,cmin,cmax,chanloc)
    standard = checkregions(chans_reg);
    if standard == 1
        nbt_plot_subregions(meanc2,1,cmin,cmax,chans_reg) % improve his function for more regions
    else
        nbt_plot_EEG_channels(chns_for_topo,cmin,cmax,chanloc)
    end
    axis square
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    drawnow
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'signrank')
        textThis = sprintf('Grand average for condition: %s (n = %i)',condition2,size(c2,2));
    else
        textThis = sprintf('Grand average for group: %s (n = %i)',condition2,size(c2,2));
    end
    nbt_split_text(xa,ya,textThis,maxline,fontsize);
    set(gca,'fontsize',fontsize)
    %---- Plot P-values
    minPValue = -2;% Plot log10(P-Values) to trick colour bar
    maxPValue = -0.5;
    subplot(4,2,7)
    chns_for_topo = nan(size(chanloc));
    for l = 1:length(regions)
        region{l} = regexprep(regions(l).reg.name,'_',' ');
        chans_reg{l} = regions(l).reg.channel_nr;
        chns_for_topo(regions(l).reg.channel_nr) = p(l);
    end
    %     nbt_plot_EEG_channels(log10(chns_for_topo),minPValue,maxPValue,chanloc);
    standard = checkregions(chans_reg);
    if standard == 1
        nbt_plot_subregions(log10(p),1,minPValue,maxPValue,chans_reg);
    else
        nbt_plot_EEG_channels(log10(chns_for_topo),minPValue,maxPValue,chanloc);
    end
    cbh = colorbar('westoutside');
    caxis([minPValue maxPValue])
    axis square
    set(cbh,'YTick',[-2 -1.3010 -1 0])
    set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
    set(get(cbh,'title'),'String','P-value');
    %     a=get(gca,'xlim');
    %     b=get(gca,'ylim');
    %     text(a(1),b(1)-(b(2)-b(1))/10,'P-values','horizontalalignment','right')
    set(gca,'fontsize',fontsize)
    drawnow
    %---text
    subplot(4,2,7)
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'signrank')
        textThis = sprintf('Grand average for condition %s minus condition %s',condition2,condition1);
    else
        textThis = sprintf('Grand average for group %s minus group %s',condition2,condition1);
    end
    nbt_split_text(xa,ya,textThis,maxline,fontsize);
    axis off
    set(gca,'fontsize',fontsize)
    
    %--- plot condition 1 errorbars per regions
    n_cnl = size(c1,1);
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'ttest2')
        [h,p,C]=ttest(c1');
    else
        for i=1:size(c1,1)
            C(:,i)=bootci(1000,@nanmedian,c1(i,:));
        end
    end
    meanc1 = statistic(c1,2);
    subplot(4,2,4)
    errorbar(1:n_cnl,meanc1,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:n_cnl,meanc1,'r.','Markersize',10)
    %     plot(1.2:n_cnl+0.2,c1','.k')
    ylim1=get(gca,'ylim');
    ylabel(unit)
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 n_cnl+0.5])
    set(gca,'fontsize',fontsize)
    drawnow
    %--- plot condition 2 errorbars per regions
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'ttest2')
        [h,p,C]=ttest(c2');
    else
        for i=1:size(c2,1)
            C(:,i)=bootci(1000,@nanmedian,c2(i,:));
        end
    end
    
    meanc2 = statistic(c2,2);
    subplot(4,2,6)
    errorbar(1:n_cnl,meanc2,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:n_cnl,meanc2,'r.','Markersize',10)
    %     plot(1.2:n_cnl+0.2,c2','.k')
    ylim2=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 n_cnl+0.5])
    set(gca,'fontsize',fontsize)
    ylabel(unit)
    %--- set axis equal for two conditions
    maxylim=max(ylim1(2),ylim2(2));
    minylim=max(ylim1(1),ylim2(1));
    set(gca,'ylim',[minylim,maxylim])
    set(gca,'XTick',1:1:n_cnl)
    set(gca,'XTickLabel','','fontsize',10)
    yaxislim = get(gca,'Ylim');
    for l = 1:length(regions)
        text(l,yaxislim(1),regexprep(regions(l).reg.name,'_',' '),'rotation',-45,'fontsize',10)
    end
    
    subplot(4,2,4)
    set(gca,'ylim',[minylim,maxylim])
    set(gca,'XTick',1:1:n_cnl)
    set(gca,'XTickLabel','','fontsize',10)
    yaxislim = get(gca,'Ylim');
    for l = 1:length(regions)
        text(l,yaxislim(1),regexprep(regions(l).reg.name,'_',' '),'rotation',-45,'fontsize',10)
    end
    
    drawnow
    
    %--- test for difference: condition 2 - condition 1, plot errorbars per
    %regions
    C = Cdiff';
    meanDiff = meanc2 - meanc1;
    subplot(4,2,8)
    errorbar(1:n_cnl,meanDiff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:n_cnl,meanDiff,'r.','Markersize',10)
    ylim1=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 n_cnl+0.5])
    set(gca,'fontsize',fontsize)
    ax=get(gca,'ylim');
    ylabel(unit)
    set(gca,'XTick',1:1:n_cnl)
    set(gca,'XTickLabel','','fontsize',10)
    yaxislim = get(gca,'Ylim');
    for l = 1:length(regions)
        text(l,yaxislim(1),regexprep(regions(l).reg.name,'_',' '),'rotation',-45,'fontsize',10)
    end
    
    drawnow
    %--- tiles and info
    y=0.1;
    
    % Title
    subplot(4,2,1)
    textThis = sprintf('Statistics for difference in "%s" between %s (n = %i) and %s (n = %i) ',regexprep(biomarker,'_',' '),...
        regexprep(condition2,'_',' '),size(c2,2),regexprep(condition1,'_',' '),size(c1,2));
    nbt_split_title([1.2 1],textThis,200,11);
    %      title(textThis,'fontweight','bold');
    subplot(4,2,1)
    text(0.5,y,'Regions','horizontalalignment','center')
    axis off
    %error Bar
    subplot(4,2,2);text(0.5,y,['Errorbars and ',statfuncname,' per regions'],'horizontalalignment','center')
    axis off
    %--- Zoom on statistics
    s.test = statfuncname;
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'signrank')
        nbt_plot_stat(diffC2C1,s,biomarker,condition2,condition1);
    else
        nbt_plot_stat(diffC2C1_2,s,biomarker,condition2,condition1);
    end
    set(gca,'XTick',1:1:size(c1,1))
    set(gca,'XTickLabel','','fontsize',10)
    yaxislim = get(gca,'Ylim');
    for l = 1:length(regions)
        text(l,yaxislim(1),regexprep(regions(l).reg.name,'_',' '),'rotation',-45,'fontsize',10)
    end
    xlabel('')
    
end
%% Nested functions part
    function plot_interpolatedTopo(ConditionNr)
        if(ConditionNr ==3)
            %CoolWarm = load('nbt_CoolWarm', 'coolWarm');
            %coolWarm = CoolWarm.coolWarm;
            %colormap(coolWarm);
            RedBlue_cbrewer10colors = load('RedBlue_cbrewer10colors','RedBlue_cbrewer10colors');
            RedBlue_cbrewer10colors = RedBlue_cbrewer10colors.RedBlue_cbrewer10colors;
            colormap(RedBlue_cbrewer10colors);
            
            if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'signrank')
                chans_Psignificant = find(p<0.05);
                %topoplot(statistic(diffC2C1,2),chanloc,'headrad','rim','numcontour',0,'electrodes','on','emarker',{'.','k',6,1},'emarker2',{[chans_Psignificant],'o','w',4,1});
                nbt_topoplot(statistic(diffC2C1,2),chanloc,'headrad','rim','numcontour',0,'electrodes','on','emarker2',{[chans_Psignificant],'o','w',4,1});
                textThis = sprintf('Grand average for condition %s minus incondition %s ',condition2,condition1);
                cmax = max(statistic(diffC2C1,2));
                cmin = min(statistic(diffC2C1,2));
              
                cmax =  max(abs([cmin cmax]));
                cmin = -1.*cmax;
                 
                caxis([cmin cmax])
                
            else
                nbt_topoplot(statistic(diffC2C1_2,2),chanloc,'headrad','rim','numcontour',3,'electrodes','off');
                textThis = sprintf('Grand average for group %s minus group %s',condition2,condition1);
                cmax = max(statistic(diffC2C1,2));
                cmin = min(statistic(diffC2C1,2));
              
                cmax =  max(abs([cmin cmax]));
                cmin = -1.*cmax;
                 
                caxis([cmin cmax])
                
            end
           
        
        else
%             nbt_redwhite = load('nbt_redwhite', 'nbt_redwhite');
%             nbt_redwhite = nbt_redwhite.nbt_redwhite;
%             colormap(nbt_redwhite);
            Reds5 = load('Reds5','Reds5');
            Reds5 = Reds5.Reds5;
            colormap(Reds5);
            
            if(ConditionNr == 1)
                nbt_topoplot(meanc1',chanloc,'headrad','rim','numcontour',0,'electrodes','on','emarker',{'.','k',6,1});
                
            else
                nbt_topoplot(meanc2',chanloc,'headrad','rim','numcontour',0 ,'electrodes','on','emarker',{'.','k',6,1});
            end
            
            cmin = min(min(meanc1),min(meanc2)); 
            cmax = max(max(meanc1),max(meanc2));
            caxis([cmin,cmax])
            
            if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'signrank')
                if(ConditionNr == 1)
                    textThis = sprintf('Grand average for  %s (n = %i)',condition1,size(c1,2));
                else
                    textThis = sprintf('Grand average for condition: %s (n = %i)',condition2, size(c2,2));
                end
            else
                if(ConditionNr == 1)
                    textThis = sprintf('Grand average for group: %s (n = %i) ',condition1,size(c1,2));
                else
                    textThis = sprintf('Grand average for group: %s (n = %i) ',condition2, size(c2,2));
                end
            end
        end
        
            
               cb = colorbar('westoutside');
            set(get(cb,'title'),'String',unit);
            
            %if (ConditionNr ~= 3)
        nTicks = size(colormap,1)+1;
        cticks = linspace(cmin,cmax,nTicks);
        % cticks(2:2:end) = []; % for more sparse tick marks
        caxis([min(cticks) max(cticks)]);
        set(cb,'YTick',cticks);
        if((abs(cmax) - abs(cmin))/nTicks<=1)
            set(cb,'YTickLabel',round(cticks/0.01)*0.01);
        else
            set(cb,'YTickLabel',round(cticks));
        end 
           % else
%                 cin = (cmax-cmin)/10;
% 
%                 set(cb,'YTick',[cmin:cin:cmax]);
%                 %set(cb,'YTickLabel',);
% 
%                 
           % end
            


           
        nbt_split_text(xa,ya,textThis,maxline,fontsize);
        axis off
        set(gca,'fontsize',fontsize)
    end

    function plot_pTopo(varargin)
        if(~isempty(varargin))
            figure;
        end
        CoolWarm = load('nbt_DarkBlueWhiteDarkRedSharp', 'nbt_DarkBlueWhiteDarkRedSharp');
        CoolWarm = CoolWarm.nbt_DarkBlueWhiteDarkRedSharp;
        colormap(CoolWarm);
        nbt_topoplot(pLog,chanloc,'headrad','rim','numcontour',3,'electrodes','off')
        cb = colorbar('westoutside');
        caxis([minPValue maxPValue])
        
        axis square
        set(cb,'YTick',[-2.3010 -1.3010 0 1.3010 2.3010])
        set(cb,'YTicklabel',[0.005 0.05 0 0.05 0.005])
    end

    function plot_interpolatedFigure(varargin)
       figure;
       subplot(2,1,1);
       plot_interpolatedTopo(1);
       subplot(2,1,2);
       plot_interpolatedTopo(2);
    end
    function plot_diffTopo(varargin)
       figure;
       plot_interpolatedTopo(3)
    end

    function print_topo(varargin)
        plot_interpolatedFigure;
        saveas(gcf, 'FigTopo.eps','epsc');
        close gcf
        plot_diffTopo;
        saveas(gcf, 'FigDiff.eps','epsc');
        close gcf
        plot_pTopo('1');
        saveas(gcf, 'FigPtopo.eps','epsc');
        close gcf
    end
% 
% filename='experiencia'
% set(gcf,'PaperPositionMode','auto')
%  print('-depsc',filename)
 

%---- check if the selected regions are equal to the default regions for
%129 EEG channels
    function standard = checkregions(chans_reg)
        if length(chans_reg) == 6
            if chans_reg{1} == [1 2 3 4 8 9 10 14 15 16 17 18 19 21 22 23 24 25 26 27 32 33 122 123 124 125 126 127 128]
                if chans_reg{2} == [28 34 35 38 39 40 41 43 44 45 46 47 48 49 50 51 56 57]
                    if chans_reg{3} == [5 6 7 11 12 13 20 29 30 31 36 37 42 54 55 79 80 87 93 104 105 106 111 112 118]
                        if chans_reg{4} == [97 98 100 101 102 103 107 108 109 110 113 114 115 116 117 119 120 121]
                            if chans_reg{5} == [52 53 58 59 60 61 62 63 64 65 66 67 68 72 77 78 84 85 86 90 91 92 94 95 96 99]
                                if chans_reg{6} == [69 70 71 73 74 75 76 81 82 83 88 89]
                                    standard = 1;
                                else
                                    standard = 0;
                                end
                            else
                                standard = 0;
                            end
                        else
                            standard = 0;
                        end
                    else
                        standard = 0;
                    end
                else
                    standard = 0;
                end
            else
                standard = 0;
            end
        else
            standard = 0;
        end
    end
end
