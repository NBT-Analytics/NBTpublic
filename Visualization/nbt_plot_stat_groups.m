% nbt_plot_stat_groups - Plot statistics 
%
% Usage:
%   nbt_plot_stat_groups(c1,c2,statdata,biomarker)
%
% Inputs:
%   c1 contains biomarker data for each subject, it's a matrix of dimension
%      n_biomarkersxn_subjects in group 1
%   c2 contains biomarker data for each subject, it's a matrix of dimension
%      n_biomarkersxn_subjects in group 2
%   statdata   is a struct containing
%             statdata.test % test name
%             statdata.statistic % statisticcs (ie. @nanmean)
%             statdata.func % statistic function (i.e. @ttest)
%             statdata.p % p-values
%             statdata.C % confidence interval
%  biomarker biomarker name (string)
%
% Outputs:
%   plot   
%
% Example:
%   
%
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2012), see NBT website (http://www.nbtwiki.net) for current email address
% Modified from Rick Jansen
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

function nbt_plot_stat_groups(varargin)
%--- assign fields
P=varargin;
nargs=length(P);
%--- 1. select Folder
c1 = P{1};
c2 = P{2};
statdata = P{3};
biomarker = P{4};
statistic = statdata.statistic;
meanc1=statistic(c1,2); %mean / median per biomarker group 1
meanc2=statistic(c2,2); %mean / median per biomarker group 2
Diffc2c1=meanc2-meanc1;

    
C = statdata.C;
statistic = statdata.statistic;
p = statdata.p;
%--- assign values:
    pointsize=15;
    nr_ch=size(c1,1);
    %--- plot errorbars and means/medians
    C = C';
    
    s=Diffc2c1;
    
    in1=find(s>0);
    in2=find(s<0);
    vec1=zeros(1,length(s));
    vec1(in1)=(C(2,in1)-C(1,in1))/2;
    vec2=zeros(1,length(s));
    vec2(in2)=(C(2,in2)-C(1,in2))/2;
%     %     error bar on both sides of mean/median:
figure('name',['NBT: ' regexprep(biomarker,'_',' ')] ,'NumberTitle','off')
set(gcf,'position',[214          51        1291         438])

    hold on
    ha= errorbar(1:nr_ch,statistic(C),vec2,vec1,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',pointsize);
    B= bar(statistic(C));
    %     error bar only on top of bar:
    ha1= errorbar(1:nr_ch,statistic(C),(C(2,:)-C(1,:))/2,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',pointsize);
    set(ha1,'visible','off')
    M=plot(1:nr_ch,statistic(C),'r.','Markersize',pointsize);
    % --- get significal p-values
    Level=0.05;
    ind=find(p<Level);
    S=plot(ind,statistic(C(:,ind)),'g.','Markersize',pointsize);
    if isempty(ind)
        S=plot(1,statistic(C(:,1)),'.g','visible','off','Markersize',pointsize);
    end
    hold off

 
    hb = get(ha,'children');
    Xdata = get(hb(2),'Xdata');
    temp = 4:3:length(Xdata);
    temp(3:3:end) = [];
    %--- xleft and xright contain the indices of the left and right
    % endpoints of the horizontal lines
    xleft = temp; xright = temp+1;
    diff=Xdata(xright)-Xdata(xleft);
    toomuch=diff-0.25;
    %--- Decreas line length by
    Xdata(xleft) = Xdata(xleft) + toomuch/2;
    Xdata(xright) = Xdata(xright) - toomuch/2;
    set(hb(2),'Xdata',Xdata)

    hb = get(ha1,'children');
    Xdata = get(hb(2),'Xdata');
    temp = 4:3:length(Xdata);
    temp(3:3:end) = [];
    %--- xleft and xright contain the indices of the left and right
    % endpoints of the horizontal lines
    xleft = temp; xright = temp+1;
    diff=Xdata(xright)-Xdata(xleft);
    toomuch=diff-0.25;
    %--- Decreas line length by
    Xdata(xleft) = Xdata(xleft) + toomuch/2;
    Xdata(xright) = Xdata(xright) - toomuch/2;
    set(hb(2),'Xdata',Xdata)

    %--- labels
    ax=get(gca,'ylim');
    axis tight
    ylim(ax)
    ax2=get(gca,'ylim');
    xlabel('Biomarker number')
    legend([M,S],'Not significant','Significant')
    ylabel(['Errorbars of ',cell2mat(statdata.test),' for the difference between Group 1 and Group 2'])
    %     title(regexprep(biomarker,'_',' '),'interpreter','none')
    %--- buttons
    button1=uicontrol('Units', 'normalized', ...
    'callback',{@set_bar} ,...
    'string','click here to show/hide bars ',...
    'position',[0.4 0    0.3000    0.0500],'Visible','on');

if (max(p)-min(p))/2~=0
     sl1=uicontrol('Units', 'normalized','style','slider','min',min(p), 'max' ,max(p) , ...
    'sliderstep',[(max(p)-min(p))/20,(max(p)-min(p))/10],'Value',(max(p)-min(p))/2, 'callback',{@set_p},...
    'position',[0 0 0.3 0.05],'Visible','on',...
    'string',[num2str(max(p)-min(p))/2]);
     TE=text( -0.1561,   -0.0498  ,['slide to change significance level: ',num2str((max(p)-min(p))/2)],'units','normalized');
end
% --- callback functions
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
        M=plot(1:nr_ch,statistic(C),'r.','Markersize',pointsize);
        S=plot(ind,statistic(C(:,ind)),'g.','Markersize',pointsize);
        hold off
        set(TE,'visible','off')
        TE=text( -0.1561,   -0.0498  ,['slide to change significance level: ',num2str(get(sl1,'value'))],'units','normalized');
        
    end
    end