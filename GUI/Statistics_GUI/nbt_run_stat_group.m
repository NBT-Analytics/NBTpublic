% nbt_run_stat_group - computes the select statistics for a single group
% and provides visualization of the results
%
% Usage:
%  [s] = nbt_run_stat_group(Group,B,s,biom,regions,unit);
%
% Inputs:
%   G is the struct variable containing informations on the selected group
%   B
%   s structure containing statistics information
%   biom
%   regions
%   unit
%
% Outputs:
%  s updated version of the input structure
%
% Example:
%  
%
% References:
% 
% See also: 
%  nbt_plot_stat, nbt_plot_group_topo
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%% ChangeLog - see version control log at NBT website for details.
%$ Version 1.1 - 25. Oct 2012: Modified by Piotr Sok??, piotr.a.sokol@gmail.com$
%%
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


function [s] = nbt_run_stat_group(Group,B,s,biom,regions,unit)
statistic=s.statistic;
statfunc =s.statfunc;
statfuncname=s.statfuncname;
statname=s.statname;
nchans_o_nregs = size(B,1);
s.biom_name = biom;
s.group_ind=evalin('caller','group_ind');
s.group_name=evalin('caller','group_name');
s.unit=unit;
s.c1=B;

if strcmp(char(statfunc),'nanmedian')
    s.C = [];
    s.p = [];
    s.c1 = [];
    s.meanc1 = statistic(B,2);
    nbt_plot_group(Group,s,biom,regions,unit);
elseif strcmp(char(statfunc),'nanmean')
    s.C = [];
    s.p = [];
    s.c1 = [];
    s.meanc1 = statistic(B,2);
    nbt_plot_group(Group,s,biom,regions,unit);
elseif strcmp(char(statfunc),'lillietest')
    for i = 1:nchans_o_nregs
        [h,p(i),statvalues(i)] = lillietest(B(i,:));
    end
    C = [];
    s.C = [];
    s.p = p;
    s.c1 = statvalues;
    s.meanc1 = [];
    nbt_plot_histfit(B,p,regions)
elseif strcmp(char(statfunc),'swtest')
    for i = 1:nchans_o_nregs
        [h,p(i),statvalues(i)] = swtest(B(i,:));
    end
    C = [];
    s.C = [];
    s.p = p;
    s.c1 = statvalues;
    s.meanc1 = [];
    nbt_plot_histfit(B,p,regions)
elseif strcmp(char(statfunc),'ttest')
    for i = 1:nchans_o_nregs
        [h,p(i),C(i,:),stats] = ttest(B(i,:));
        statvalues(i) = stats.tstat;
    end    
    s.C = C;
    s.p = p;
    s.c1 = B;
    s.meanc1 = statistic(B,2);
    nbt_plot_group(Group,s,biom,regions,unit);
elseif strcmp(char(statfunc),'signrank')
    for i = 1:nchans_o_nregs
        [p(i),h,stats] = signrank(B(i,:));
        C(i,:)=bootci(1000,statistic,B(i,:));
        statvalues(i) = stats.signedrank;
                    s.C = C;
            s.p = p;
            s.c1 = B;
            s.meanc1 = statistic(B,2);
    end
    nbt_plot_group(Group,s,biom,regions,unit);
elseif strcmp(char(statfunc),'ttest2')
    warning('This test requires more than 1 group');
elseif strcmp(char(statfunc),'ranksum')
    warning('This test requires more than 1 group');
elseif strcmp(char(statfunc),'nbt_perm_group_diff')
    warning('This test requires more than 1 group');
elseif strcmp(char(statfunc),'nbt_perm_corr')
    warning('This test requires more than 1 group');
elseif strcmp(char(statfunc),'zscore')
%     B = abs(B); % absolute values for a difference group e.g.
    dim = 2;
    sigma = nanstd(B,1,dim);
    mu = nanmean(B,dim);
    sigma(sigma==0) = 1;
    z = bsxfun(@minus,B, mu);
    z = bsxfun(@rdivide, z, sigma);
    s.mu=mu;
    s.sigma=sigma;
    s.vals=z;
end

% -----------------------------------------------
% plot histogram
    function nbt_plot_histfit(B,p,regions)
    
    d = round(sqrt(size(B,1)));
    if d*d< size(B,1)
        d1 = d;
        d2 = d+1;
    else
        d1 = d;
        d2 = d;
    end
    figure('Name',['Histogram with normal fit: ' biom],'Units','points','numbertitle','off','Position',[200 50 900  500])
    for i = 1:size(B,1)
        hold on
        subplot(d1,d2,i);
        histfit(B(i,:));
        x = get(gca,'xlim');
        y = get(gca,'ylim');
        text(x(1),y(2)-0.2*y(2),['p = ' num2str(p(i))],'Color','r')
        set(gca,'fontsize',8)
        xlabel(['Channel ', num2str(i)])
    end
    figure('Name',['QQPlot: ' biom ],'Units','points','numbertitle','off','Position',[200 50 900  500])
    for i = 1:size(B,1)
        hold on
        subplot(d1,d2,i);
        qqplot(B(i,:));
        x = get(gca,'xlim');
        y = get(gca,'ylim');
        text(x(1),y(2)-0.2*y(2),['p = ' num2str(p(i))],'Color','r')
        set(gca,'fontsize',8)
        set(gca,'fontsize',8)
        xlabel(['Channel ', num2str(i)])
        ylabel('')
        title('')
    end    
    figure('Name',['Normality Test, P-values: ' biom],'Units','points','numbertitle','off','Position',[200 50 900  500])
    bar(1:size(B,1),p)
    for l = 1:size(B,1)
        if p(l)<=0.05% reject null hypothesis
            hold on 
            plot(l,max(p)+0.1*max(p),'r*')
        end
    end
    axis tight
    if isempty(regions)
        set(gca,'XTick',1:1:size(B,1))
        set(gca,'XTickLabel',1:1:size(B,1),'fontsize',5)
        xlabel('channels','fontsize',12)
    else
%         labelX = {''};
%         for l = 1:length(regions)
%             labelX = {labelX{1:end}, regions(l).reg.name};
%         end
%         labelX = labelX(2:end);
        set(gca,'XTick',1:1:size(B,1))
        set(gca,'XTickLabel','','fontsize',5)
        for l = 1:length(regions)
            text(l,0,regions(l).reg.name,'rotation',45,'horizontalalignment','right','fontsize',6)
        end
        xlabel('regions','fontsize',12)
    end
        
    ylabel('p-values','fontsize',12)
    ylim([0 max(p)+0.2*max(p)])
    end

%-------------------------------------------------
     function [s] = nbt_plot_group(Group,s,biom,regions,unit)
            chanloc = Group.chansregs.chanloc; 
            channel_nr = Group.chansregs.channel_nr;
            
         %in case chanloc does not correspond to the channels you want to plot   
          if length(chanloc) ~= length(channel_nr)
                
                chanloc=chanloc(1:length(channel_nr));
            end
%             s.C = C;
%             s.p = p;
%             s.c1 = B;
%             s.meanc1 = statistic(B,2);


            if isempty(regions) 
                if(~isempty(s.p))
                    nbt_plot_stat(s.c1,s,biom)
                end
%                 set(gca,'XTick',1:1:size(B,1))
%                 set(gca,'XTickLabel',1:1:size(B,1),'fontsize',5)
%                 xlabel('channels','fontsize',12)
                nbt_plot_group_topo(chanloc,s,biom,unit,regions)

            else
                if(~isempty(s.p))
                    nbt_plot_stat(s.c1,s,biom)
                end
                set(gca,'XTick',1:1:size(s.c1,1))
                set(gca,'XTickLabel','','fontsize',5)
                for l = 1:length(regions)
                    text(l,0,regexprep(regions(l).reg.name,'_',' '),'rotation',45,'horizontalalignment','right','fontsize',6)
                end
                xlabel('regions','fontsize',12)
                nbt_plot_group_topo(chanloc,s,biom,unit,regions)
            end
     end
 end