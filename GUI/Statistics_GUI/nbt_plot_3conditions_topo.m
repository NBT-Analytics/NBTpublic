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


function nbt_plot_3conditions_topo(Group1,Group2,Group3,chanloc,s,unit,biomarker)


tmp1 = findstr(Group1.fileslist(1).name,'.');
tmp2 = findstr(Group1.fileslist(1).name,'_');
condition1 = Group1.fileslist.group_name;
tmp1 = findstr(Group2.fileslist(1).name,'.');
tmp2 = findstr(Group2.fileslist(1).name,'_');
condition2 = Group2.fileslist.group_name;
tmp1 = findstr(Group3.fileslist(1).name,'.');
tmp2 = findstr(Group3.fileslist(1).name,'_');
condition3 = Group3.fileslist.group_name;


p = s.p;
for m =1:size(s.DataCell,1)
DataTmp=s.DataCell{m,1};
c1(m,:) = DataTmp(:,1)';
c2(m,:) = DataTmp(:,2)';
c3(m,:) = DataTmp(:,3)';
end
clear DataTmp
meanc1=s.statistic(c1,2); %mean / median per channel condition 1
meanc2=s.statistic(c2,2); %mean / median per channel condition 2
meanc3=s.statistic(c2,2);


if size(c1,2) == size(c2,2)
    diffC2C1 = c2-c1;
else
    diffC2C1 = [];
end
diffC2C1_2 = meanc2-meanc1;
statistic=s.statistic;

statfuncname={s.statfuncname};
fontsize = 10;

    
    fontsize = 10;
    fig1 = figure('name',['NBT: Statistics (Channels) for ',regexprep(biomarker,'_',' ')],...
        'NumberTitle','off','position',[10          80       1500      500]); %128
    fig1=nbt_movegui(fig1);
    
    % ---for color scale in following plots
    vmax=max([meanc1,meanc2, meanc3]);
    vmin=min([meanc1,meanc2, meanc3]);
    cmax = max(vmax);
    cmin = min(vmin);
  %  cmin = 0;
    
    xa=-2.5;
    ya = 0.25;
    maxline = 20;

    nbt_redwhite = load('nbt_redwhite', 'nbt_redwhite');
    nbt_redwhite = nbt_redwhite.nbt_redwhite;
    colormap(nbt_redwhite);
    %---plot grand average condition 1 per channel(Interpolated Plot)
    subplot(4,3,4)
    topoplot(meanc1',chanloc,'headrad','rim','numcontour',3, 'electrodes','off');
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    cbfreeze
    freezeColors
    drawnow

        textThis = sprintf('Grand average for group: %s (n = %i) ',condition1,sum(sum(isnan(c1),1)<size(c1,1)));
  
    nbt_split_text(xa,ya,textThis,maxline,fontsize);
    set(gca,'fontsize',fontsize)
    %---plot grand average condition 1 per channel(Actual Channels)
    subplot(4,3,5)
    nbt_plot_EEG_channels(meanc1,cmin,cmax,chanloc,nbt_redwhite,unit);
    %---plot grand average condition 2 per channel(Interpolated Plot)
    subplot(4,3,7)
    topoplot(meanc2',chanloc,'headrad','rim','numcontour',3,'electrodes','off');
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])

        textThis = sprintf('Grand average for group: %s (n = %i) ',condition2, sum(sum(isnan(c2),1)<size(c2,1)));
 
    nbt_split_text(xa,ya,textThis,maxline,fontsize);
    set(gca,'fontsize',fontsize)
    cbfreeze
    freezeColors
    drawnow
    
      %---plot grand average difference between conditions or difference between group means (Interpolated Plot)
    subplot(4,3,10)
    OldColorMap = colormap;
 
    colormap(nbt_redwhite);
        topoplot(meanc3',chanloc,'headrad','rim','numcontour',3,'electrodes','off');
        textThis = sprintf('Grand average for group: %s (n = %i)',condition3,sum(sum(isnan(c3),1)<size(c3,1)));

    cb = colorbar('westoutside');
    caxis([cmin,cmax])
    set(get(cb,'title'),'String',unit);
    nbt_split_text(xa,ya,textThis,maxline,fontsize);
    axis off
    set(gca,'fontsize',fontsize)
    freezeColors
    cbfreeze
    drawnow
    
    %---plot grand average condition 2 per channel(Actual Channels)
    subplot(4,3,8)
    nbt_plot_EEG_channels(meanc2,cmin,cmax,chanloc,nbt_redwhite,unit);
    %---plot P-values for the test (log scaled colorbar)
    %minPValue = -2;% Plot log10(P-Values) to trick colour bar - 
    %maxPValue = -0.5;
    % red white blue color scale
    minPValue = log10(0.0005);
    maxPValue = -log10(0.0005);
    p = log10(p); % to make it log scaled

        p = sign(statistic(diffC2C1_2,2))'.*p;

    p = -1*p;
    p( p<minPValue) = minPValue;
    p(p> maxPValue) = maxPValue;
    
    
    
    subplot(4,3,11)
    CoolWarm = load('nbt_DarkBlueWhiteDarkRed', 'nbt_DarkBlueWhiteDarkRed');
    CoolWarm = CoolWarm.nbt_DarkBlueWhiteDarkRed;
    colormap(CoolWarm);
    topoplot(p,chanloc,'headrad','rim','numcontour',3);
    cb = colorbar('westoutside');
    caxis([minPValue maxPValue])
   
    axis square
     set(cb,'YTick',[-2.3010 -1.3010 0 1.3010 2.3010])
     set(cb,'YTicklabel',[0.005 0.05 0 0.05 0.005])
    
     drawnow
  
     cbfreeze 
    
        
 %   nbt_plot_EEG_channels(p,minPValue,maxPValue,chanloc,CoolWarm,'P-values');

    %     a=get(gca,'xlim');
    %     b=get(gca,'ylim');
    %     text(a(1),b(1)-(b(2)-b(1))/10,'P-values','horizontalalignment','right')
    
  
  
end
    