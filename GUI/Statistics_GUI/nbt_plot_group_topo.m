% nbt_plot_group_topo - topoplot for within group statistics
%
% Usage:
%  nbt_plot_group_topo(chanloc,statdata,biomarker,unit,regions)
%
% Inputs:
%   chanloc, channels location
%   statdata, struct containing statistics info and results
%   biomarker,
%   unit,
%   regions
%
% Outputs:
%
% Example:
%  
%
% References:
% 
% See also: 
%  nbt_plot_subregions,nbt_plot_EEG_channels
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
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

function nbt_plot_group_topo(chanloc,statdata,biomarker,unit,regions)

c1 = statdata.c1;
meanc1 = statdata.meanc1;
vmax=max(meanc1);
vmin=min(meanc1);
C = statdata.C;
cmax = vmax; 
cmin = vmin;
statistic = statdata.statistic;
p = statdata.p;
fontsize = 10;
if isempty(regions)
    
%--- set figure
    figure('name',['NBT: Statistics (Channels) for ',regexprep(biomarker,'_',' ')],'NumberTitle','off')
    set(gcf,'position',[10          80       1500      500]) %128
% ---for color scale in following plots
    xa=-2;
    coolWarm = load('nbt_CoolWarm.mat','coolWarm');
    coolWarm = coolWarm.coolWarm;
    colormap(coolWarm);
%---plot grand average condition 1 per channel(Interpolated Plot)    
    subplot(2,3,4)
    topoplot(meanc1',chanloc,'headrad','rim');
    axis square
    cb = colorbar('westoutside');
    set(get(cb,'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
%---plot grand average condition 1 per channel(Actual Channels)
    subplot(2,3,5)
    nbt_plot_EEG_channels(meanc1,cmin,cmax,chanloc,coolWarm,[]);
    axis square
    cb = findobj(gcf,'tag','Colorbar');
    set(get(cb(end),'title'),'String',unit);
    caxis([cmin,cmax])
    set(gca,'fontsize',fontsize)
    
    % -- plot statistics    
    if ~isempty(C)
        subplot(2,3,6)
        %--- assign values:
        pointsize=15;
        nr_ch=size(c1,1);
        %--- plot errorbars and means/medians
        C = C';
        diff_channels=statistic(C);
        %medium confidence interval
        %--- error bar on both sides of mean/median:
        %-----------------------------------------
        errorbar(1:nr_ch,diff_channels,(C(2,:)-C(1,:))/2,'linestyle','none', ...
            'markeredgecolor','red','marker','none','markersize',pointsize);
        hold on
        plot(1:nr_ch,diff_channels,'r.','Markersize',10)
        %         plot(1.2:nr_ch+0.2,c1','.k')
        ylim1=get(gca,'ylim');
        ylabel(unit)
        hold off
        xlabel('Channels')
        set(gca,'xlim',[0.5 nr_ch+0.5])
        set(gca,'fontsize',fontsize)
    end
%--- tiles and info
    y=0.1;
    subplot(2,3,1)
    text(0.5,y,'Interpolated topoplot','horizontalalignment','center')
    axis off

    subplot(2,3,2);text(0.5,0.5,[char(statdata.statfunc),' for ',regexprep(biomarker,'_',' ')],'horizontalalignment','center','fontweight','bold')
    axis off

    subplot(2,3,2)
    text(0.5,y,'Actual channels','horizontalalignment','center')
    axis off

    subplot(2,3,3)
    text(0.5,y,['Errorbars per channels'],'horizontalalignment','center')
    axis off
else
%--- set figure    
   figure('name',['NBT: Statistics (Regions) for ',regexprep(biomarker,'_',' ')],'NumberTitle','off')
   set(gcf,'position',[10          80       1500      500]) %128
% ---for color scale in following plots
  rmax=max(meanc1);
  rmin=min(meanc1);
  cmax = max([vmax, rmax]);
  cmin = min([vmin, rmin]);
  xa=-2;
  coolWarm = load('nbt_CoolWarm.mat','coolWarm');
  coolWarm = coolWarm.coolWarm;
  colormap(coolWarm);
%---plot grand average condition 1 per regions
  chns_for_topo = nan(size(chanloc));
  for l = 1:length(regions)
       region{l} = regexprep(regions(l).reg.name,'_',' ');
       chans_reg{l} = regions(l).reg.channel_nr; 
       chns_for_topo(regions(l).reg.channel_nr) = meanc1(l);
  end
  subplot(2,3,4)
%       nbt_plot_EEG_channels(chns_for_topo,cmin,cmax,chanloc)     
  standard = checkregions(chans_reg);
  if standard == 1
      nbt_plot_subregions(meanc1,1,cmin,cmax,chans_reg); % improve his function for more regions
  else
      nbt_plot_EEG_channels(meanc1,cmin,cmax,chanloc,coolWarm,[]);
  end
  axis square
  cb = colorbar('westoutside');
  set(get(cb,'title'),'String',unit);
  caxis([cmin,cmax])
  set(gca,'fontsize',fontsize)
%--- plot condition 1 errorbars per regions
    C = C';
    diff_regions=statistic(C);
    subplot(2,3,[5 6])
    errorbar(1:6,diff_regions,(C(2,:)-C(1,:))/2,'linestyle','none', ...
            'markeredgecolor','red','marker','none','markersize',10)
    hold on
    plot(1:6,diff_regions,'r.','Markersize',10)
    plot(1.2:6.2,c1','.k')
    ylim1=get(gca,'ylim');
    for i=1:6
        text(i,ylim1(1),region{i},'rotation',45,'horizontalalignment','right','fontsize',fontsize)
    end
    ylabel(unit)
    hold off
    set(gca,'xtick',[])
    set(gca,'xlim',[0.5 6.5])
    set(gca,'fontsize',fontsize)
%--- tiles and info
    y=0.1;

    subplot(2,3,2);text(0.5,0.5,[char(statdata.statfunc),' for ',regexprep(biomarker,'_',' ')],'horizontalalignment','center','fontweight','bold')
    axis off

    subplot(2,3,1);text(0.5,y,[char(statdata.statistic),' per subregions'],'horizontalalignment','center')
    axis off

    subplot(2,3,3);text(0.5,y,['Errorbars per subregion'],'horizontalalignment','center')
    axis off

end

%---- check if the selected regions are equal to the default regions for
%129 EEG channels
function standard = checkregions(chans_reg)

if length(chans_reg) == 6    
    if chans_reg{1} == [1 2 3 4 8 9 10 14 15 16 17 18 19 21 22 23 24 25 26 27 32 33 122 123 124 125 126 127 128]
        if chans_reg{2} == [28 34 35 38 39 40 41 43 44 45 46 47 48 49 50 51 56 57]
            if chans_reg{3} == [5 6 7 11 12 13 20 29 30 31 36 37 42 54 55 79 80 87 93   104 105 106 111 112 118] 
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