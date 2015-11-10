%  nbt_plot_2conditions_NoChansBiom - topoplot for statistics with two groups or conditions
%
% Usage:
% nbt_plot_2conditions_NoChansBiom(Group1,Group2,s,unit,biomarker,regions)
%
% Inputs:
%   Group1,
%   Group2,
%   s,
%   unit,
%   biomarker,
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
% Originally created by Rick Jansen and later modified by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
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
% --------------


function h3 = nbt_plot_2conditions_NoChansBiom(Group1,Group2,s,unit,biomarker)
tmp1 = findstr(Group1.fileslist(1).name,'.');
tmp2 = findstr(Group1.fileslist(1).name,'_');
condition1 = Group1.fileslist.group_name;
tmp1 = findstr(Group2.fileslist(1).name,'.');
tmp2 = findstr(Group2.fileslist(1).name,'_');
condition2 = Group2.fileslist.group_name;

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
y = 0.1;
    fontsize = 10;
    fig1 = figure('name',['NBT: Statistics for ',regexprep(biomarker,'_',' ')],...
        'NumberTitle','off','position',[10          80      1300      500]); %128
     fig1=nbt_movegui(fig1);

   

% ---for color scale in following plots
    vmax=max([meanc1,meanc2]);
    vmin=min([meanc1,meanc2]);
    cmax = max(vmax); 
    cmin = min(vmin);
   
    xa=-2.5;
    ya = 0.25;
    maxline = 20;
    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
    coolWarm = coolWarm.coolWarm;
    colormap(coolWarm);

%--- plot condition 1 errorbars per channels
    n_cnl = size(c1,1);
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'ttest2')
        [h,p,C]=ttest(c1');
    else
        for i=1:size(c1,1)
            C(:,i)=bootci(1000,@nanmedian,c1(i,:));
        end
    end
    diff=statistic(C);
    h1 = subplot(3,1,1);
    errorbar(1:n_cnl,diff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:n_cnl,diff,'r.','Markersize',10)
%     plot(1.2:n_cnl+0.2,c1','.k')
    ylim1=get(gca,'ylim');
    ylabel(unit)
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 n_cnl+0.5])
    set(gca,'fontsize',fontsize)
    drawnow
%--- plot condition 1 errorbars per channels
    if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'ttest2')
        [h,p,C]=ttest(c2');
    else
        for i=1:size(c2,1)
            C(:,i)=bootci(1000,@nanmedian,c2(i,:));
        end
    end
    diff=statistic(C);
     h2 = subplot(3,1,2);
    errorbar(1:n_cnl,diff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:n_cnl,diff,'r.','Markersize',10)
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
%     xlabel('Channels')
    subplot(3,1,3)
    set(gca,'ylim',[minylim,maxylim])
%     xlabel('Channels')
    drawnow
%--- test for difference: condition 2 - condition 1, plot errorbars per
%channels
    C = Cdiff';
    diff=statistic(C);
    h3 = subplot(3,1,3);
    errorbar(1:n_cnl,diff,(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:n_cnl,diff,'r.','Markersize',10)
    ylim1=get(gca,'ylim');
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 n_cnl+0.5])
    set(gca,'fontsize',fontsize)
    ax=get(gca,'ylim');
%     xlabel('Channels')
    ylabel(unit)
    drawnow
%--- tiles and info
%   
%   Title
    subplot(3,1,1)
   textThis = sprintf('Statistics for difference in "%s" between %s (n = %i) and %s (n = %i) ',regexprep(biomarker,'_',' '),...
       regexprep(condition2,'_',' '),size(c2,2),regexprep(condition1,'_',' '),size(c1,2));
%    nbt_split_title([0.2 1],textThis,200,11);
title(textThis)

%     title(textThis,'fontweight','bold');
%   Error Bar   
    subplot(3,1,1);
    xlim = get(h1,'xlim');
    ylim = get(h1,'ylim');
    text(xlim(1),ylim(2)+0.01*ylim(2),['Errorbars for each voice for condition ', regexprep(condition1,'_',' ')],'Parent',h1,'fontweight','bold')
    ylabel('score')
  subplot(3,1,2);
    xlim = get(h2,'xlim');
    ylim = get(h2,'ylim');
    text(xlim(1),ylim(2)+0.01*ylim(2),['Errorbars for each voice for condition ', regexprep(condition2,'_',' ')],'Parent',h2,'fontweight','bold')
  ylabel('score ')
    subplot(3,1,3);
    xlim = get(h3,'xlim');
    ylim = get(h3,'ylim');
    text(xlim(1),ylim(2)+0.01*ylim(2),['Errorbars for each voice for condition ', regexprep(condition2,'_',' '), ' minus ', regexprep(condition1,'_',' ')],'Parent',h3,'fontweight','bold')
    ylabel('score difference')
% %--- Zoom on statistics
%     s.test = statfuncname;    
%     if strcmp(char(statfunc),'ttest') || strcmp(char(statfunc),'signrank')
%         nbt_plot_stat(diffC2C1,s,biomarker,condition2,condition1);
%     else
%         nbt_plot_stat(diffC2C1,s,biomarker,condition2,condition1);
%     end
    
