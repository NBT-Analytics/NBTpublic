% nbt_plot_stat - Plot statistics 
%
% Usage:
%   nbt_plot_stat(c1,statdata,biomarker,cond1,cond2) % used in stat between
%   conditions
%   or 
%   nbt_plot_stat(c1,statdata,biomarker)
%
% Inputs:
%   c1 contains biomarker data for each subject, it's a matrix of dimension
%      n_biomarkersxn_subjects
%   statdata   is a struct containing
%             statdata.statfuncname % test name
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
%   nbt_plot_stat(diffC2C1,statdata,biomarker, cond1, cond2);
%
% References:
% 
% See also: 
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

function nbt_plot_stat(varargin)
%--- assign fields
P=varargin;
nargs=length(P);
%--- 1. select Folder
c1 = P{1};
statdata = P{2};
biomarker = P{3};
if nargs<4 || isempty(P{4})
    cond1 = [];
    cond2 = [];
else
    cond1 = P{4};
    cond2 = P{5};
end
C = statdata.C;
statistic = statdata.statistic;
p = statdata.p;
%--- assign values:
pointsize=15;
nr_ch=size(c1,1);
%--- plot errorbars and means/medians
C = C';
s=statistic(C);
in1=find(s>0);
in2=find(s<0);
vec1=zeros(1,length(s));
vec1(in1)=(C(2,in1)-C(1,in1))/2;
vec2=zeros(1,length(s));
vec2(in2)=(C(2,in2)-C(1,in2))/2;
%--- error bar on both sides of mean/median:
figure('name',['NBT: ' regexprep(biomarker,'_',' ')] ,'NumberTitle','off')
set(gcf,'position',[214          51        1291         700])
subplot(4,1,[2 3])
hold on
ha= errorbar(1:nr_ch,statistic(C),vec2,vec1,'linestyle','none', ...
        'markeredgecolor','red','marker','none','markersize',pointsize);
B= bar(statistic(C));
%--- error bar only on top of bar:
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
%--- plot individual data points
ax1=get(gca,'ylim');
hold on
P= plot([1:nr_ch]+0.2,c1,'.k') ;
hold off
%--- labels
ax=get(gca,'ylim');
axis tight
ylim(ax)
ax2=get(gca,'ylim');
% xlabel('Biomarker number')
legend([M,S],'Not significant','Significant')
if isempty(cond1) && isempty(cond2) 
    ylabel(['Errorbars of ',char(statdata.statfuncname),' for ',regexprep(biomarker,'_',' ')],'interpreter','none')
else
    ylabel(['Errorbars of ',char(statdata.statfuncname),' for the difference between conditions ',regexprep(cond2,'_',' '), ' and ' regexprep(cond1,'_',' '),])

end
%     title(regexprep(biomarker,'_',' '),'interpreter','none')
%--- buttons
button1=uicontrol('Units', 'normalized', ...
'callback',{@set_bar} ,...
'string','click here to show/hide bars ',...
'position',[0.4 0    0.3000    0.0500],'Visible','on');

button2=uicontrol('Units', 'normalized', ...
'callback',{@set_points} ,...
'string','click here to show/hide data points ',...
'position',[0.75 0 0.3 0.05],'Visible','on');
if (max(p)-min(p))/2~=0
     sl1=uicontrol('Units', 'normalized','style','slider','min',min(p), 'max' ,max(p) , ...
    'sliderstep',[(max(p)-min(p))/20,(max(p)-min(p))/10],'Value',min(p)+(max(p)-min(p))/2, 'callback',{@set_p},...
    'position',[0 0 0.3 0.05],'Visible','on',...
    'string',[num2str(min(p)+(max(p)-min(p))/2)]);

%      TE=text( -0.1561,   -0.0498   ,['slide to change significance level: ',num2str(min(p)+(max(p)-min(p))/2)],'units','normalized');
TE=text( -0.1561,   -0.6  ,['slide to change significance level: ',num2str(min(p)+(max(p)-min(p))/2)],'units','normalized');
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

function[]=set_points(d1,d2,x,h)
    if strcmp(get(P,'visible'),'on')
        set(P,'visible','off')
        set(gca,'ylim',ax1);
    else
        set(P,'visible','on')
        set(gca,'ylim',ax2);
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