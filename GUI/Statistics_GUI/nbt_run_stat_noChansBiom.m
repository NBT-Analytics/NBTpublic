% nbt_run_stat_noChansBiom - computes the select statistics for a single group
% and provides visualization of the results
%
% Usage:
%  [s] = nbt_run_stat_noChansBiom(Group,B,s,biom,unit);
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
%
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2012), see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%% ChangeLog - see version control log at NBT website for details.
%$ Version 1.1 - 25. Oct 2012: Modified by Piotr Sok�, piotr.a.sokol@gmail.com$
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


function [s] = nbt_run_stat_noChansBiom(Group,B,s,biom,unit)
statistic=s.statistic;
statfunc =s.statfunc;
statfuncname=s.statfuncname;
statname=s.statname;
nchans_o_nregs = (size(B,1));
s.biom_name = biom;
s.group_ind=evalin('caller','group_ind');
s.group_name=evalin('caller','group_name');
s.unit=unit;
s.c1=B;

if strcmp(char(statfunc),'nanmedian')
%       nbt_plot_group(Group,B,[],[],statistic,statfuncname,biom,regions,unit);
    if sqrt(size(B,1)) == length(Group.chansregs.chanloc)
        s.C=[];
        s.p=[];
        nbt_array2squaremat(B,s,Group,s.C,s.p)
    else
        s.C=[];
        s.p=[];
        nbt_plot_group_notopos(Group,B,s.C,s.p,statistic,statfuncname,biom,unit);
    end
elseif strcmp(char(statfunc),'lillietest')
    for i = 1:nchans_o_nregs
        [h,p(i),statvalues(i)] = lillietest(B(i,:));
    end
    s.C = [];  
    s.p=p;
    nbt_plot_histfit(B,s.p,[])    
elseif strcmp(char(statfunc),'swtest')
    for i = 1:nchans_o_nregs
        [h,p(i),statvalues(i)] = swtest(B(i,:));
    end
    s.p=p;
    C = [];
    nbt_plot_histfit(B,s.p,[])
elseif strcmp(char(statfunc),'ttest')
   for i = 1:nchans_o_nregs
    [h,p(i),C(i,:),stats] = ttest(B(i,:));
    statvalues(i) = stats.tstat;
   end    
   s.p=p;
   s.C=C;
    if sqrt(size(B,1)) == length(Group.chansregs.chanloc)
        nbt_array2squaremat(B,s,Group,s.C,s.p)%     nbt_plot_group(Group,squeeze(B2(1,:,:)),C2,p2,statistic,statfuncname,
%     biom,[],unit);
    else size(B,1) 
        nbt_plot_group_notopos(Group,B,s.C,s.p,statistic,statfuncname,biom,unit);
    end
elseif strcmp(char(statfunc),'signrank')
    for i = 1:nchans_o_nregs
        [p(i),h,stats] = signrank(B(i,:));
        C(i,:)=bootci(1000,statistic,B(i,:));
        statvalues(i) = stats.signedrank;
    end
    s.C=C;
    s.p=p;
    if sqrt(size(B,1)) == length(Group.chansregs.chanloc)
        nbt_array2squaremat(B,s,Group,s.C,s.p)%     nbt_plot_group(Group,squeeze(B2(1,:,:)),C2,p2,statistic,statfuncname,
%     biom,[],unit);
    else
       nbt_plot_group_notopos(Group,B,s.C,s.p,statistic,statfuncname,biom,unit);
    end
elseif strcmp(char(statfunc),'ttest2')
    warning('This test requires more than 1 group');
elseif strcmp(char(statfunc),'ranksum')
    warning('This test requires more than 1 group');
elseif strcmp(char(statfunc),'nbt_perm_group_diff')
    warning('This test requires more than 1 group');
elseif strcmp(char(statfunc),'nbt_perm_corr')
    warning('This test requires more than 1 group');
elseif strcmp(char(statfunc),'zscore')
    dim=2;
    sigma=nanstd(B,1,dim);
    mu=nanmean(B,dim);
    sigma(sigma==0) = 1;
    z = bsxfun(@minus,B, mu);
    z = bsxfun(@rdivide, z, sigma);
    counter=evalin('caller','i');
    s.group_ind=evalin('caller','group_ind');

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
%         xlabel('channels','fontsize',12)
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
    function [s] = nbt_plot_group_notopos(Group,B,C,p,statistic,statfuncname,biom,unit);
            s.C = C;
            s.p = p;
            s.c1 = B;
            s.meanc1 = statistic(B,2);
            s.test = {statfuncname};
            s.statistic = statistic;
            s.unit = unit;
            s.biom = biom;
            [firstname,secondname]=strtok(biom,'.');
            
            data = load([Group.fileslist(1).path '/' Group.fileslist(1).name],firstname);
            name = genvarname(char(fields(data)));
            
            if eval(['isa(data.' name ',''nbt_questionnaire'')']);
                eval(['questions = data.' name '.Questions;'])
                questions = questions(1:size(B,1));
            else
                questions = 1:size(B,1);
            end
            if strcmp(char(statistic),'nanmedian')
                sem = mad(B,1,2)/0.6745/sqrt(size(B,2));
            elseif strcmp(char(statistic),'nanmean')
                sem = nanstd(B,[],2)/sqrt(size(B,2));
            end
            scrsz = get(0,'ScreenSize');
            if(~isempty(p))
                 nbt_plot_stat(B,s,biom)
                 set(gca,'xtick',1:size(B,1),'xticklabel',questions)
                xtick=1:size(B,1);
                xticklabel=questions;
                limy = get(gca,'ylim');
                h = get(gca,'xlabel');
                xlabelstring = get(h,'string');
                xlabelposition = get(h,'position');
                yposition = xlabelposition(2);
                yposition = limy(1)*ones(size(questions));%repmat(yposition,length(xtick),1);
                set(gca,'xtick',[]);
                hnew = text(xtick, yposition, xticklabel);
                set(hnew,'rotation',60,'horizontalalignment','right','fontsize',10,'fontweight','bold');
            else
            figure
            subplot(2,1,1)
            errorbar(s.meanc1,sem,'.')
            hold on
            bar(s.meanc1) 
            title([char(statistic) ' for ' biom])
            axis tight
            set(gca,'xtick',1:size(B,1),'xticklabel',questions)
            xtick=1:size(B,1);
            xticklabel=questions;
            limy = get(gca,'ylim');
            h = get(gca,'xlabel');
            xlabelstring = get(h,'string');
            xlabelposition = get(h,'position');
            yposition = xlabelposition(2);
            yposition = limy(1)*ones(size(questions));%repmat(yposition,length(xtick),1);
            set(gca,'xtick',[]);
            hnew = text(xtick, yposition, xticklabel);
            set(hnew,'rotation',45,'horizontalalignment','right','fontsize',10);
            end
    end
%-------------------------------------------------
      function [s] = nbt_plot_group(Group,B,C,p,statistic,statfuncname,biom,regions,unit)
            chanloc = Group.chansregs.chanloc; 
            s.C = C;
            s.p = p;
            s.c1 = B;
            s.meanc1 = statistic(B,2);
            s.statfuncname = statfuncname;
            s.statistic = statistic;
            s.unit = unit;
            s.biom = biom;
            s.statfunc=statfunc;
%             assignin('base','s',s)
            if isempty(regions) 
                if(~isempty(p))
                    nbt_plot_stat(B,s,biom)
                end
%                 set(gca,'XTick',1:1:size(B,1))
%                 set(gca,'XTickLabel',1:1:size(B,1),'fontsize',5)
%                 xlabel('channels','fontsize',12)
%                 nbt_plot_group_topo(chanloc,s,biom,unit,regions)
                  nbt_plot_group_topo(chanloc,s,biom,unit,regions)
            else
                if(~isempty(p))
                    nbt_plot_stat(B,s,biom)
                end
%                 set(gca,'XTick',1:1:size(B,1))
%                 set(gca,'XTickLabel','','fontsize',5)
%                 for l = 1:length(regions)
%                     text(l,0,regexprep(regions(l).reg.name,'_',' '),'rotation',45,'horizontalalignment','right','fontsize',6)
%                 end
%                 xlabel('regions','fontsize',12)
%                 nbt_plot_group_topo(chanloc,s,biom,unit,regions)
            end
     end
 %%
    function nbt_coord2plot_group(HOBJ,EVENTDATA,C,p,regions,unit,B2);
        
        pos_cursor_unitfig = get(gca,'currentpoint');
        chan_or_reg = round(pos_cursor_unitfig(1,2));
        biomarker = round(pos_cursor_unitfig(1,1));
        if ~isempty(C) && ~isempty(p)
            C=squeeze(C(biomarker,:,:));
            p=squeeze(p(biomarker,:,:));
        end
%         nbt_plot_group(C,p,regions,unit);
%         nbt_plot_group(Group,B,C,p,statistic,statfuncname,biom,[],unit);

        nbt_plot_group(Group,squeeze(B2(biomarker,:,:)),C,p,statistic,statfuncname,strcat(biom,' (',int2str(biomarker),', : )'),regions,unit);
% disp('Testing');
    end
%------------------------------------------------
    function nbt_biom2plot_group(HOBJ,EVENTDATA,C,p,regions,unit,B2);
        biomarker = str2num(cell2mat(inputdlg('Which channel do you want to plot?: ' )));
        if ~isempty(C) && ~isempty(p)
            C=squeeze(C(biomarker,:,:));
            p=squeeze(p(biomarker,:,:));
        end
        nbt_plot_group(Group,squeeze(B2(biomarker,:,:)),C,p,statistic,statfuncname,strcat(biom,' (',int2str(biomarker),', : )'),regions,unit);
    end
%------------------------------------------------
    function nbt_array2squaremat(B,s,Group,C,p)
        medianB = s.statistic(B,2)';
        medianBresh = reshape(medianB,sqrt(size(B,1)),sqrt(size(B,1)));
        figure();
        bh=imagesc(medianBresh);
        hh=uicontextmenu;
        hh2 = uicontextmenu;
        colorbar('off')
        coolWarm = load('nbt_CoolWarm.mat','coolWarm');
        coolWarm = coolWarm.coolWarm;
        colormap([0,0,0;coolWarm]);
        cbh = colorbar('EastOutside');
        bioms_name={biom};
        set(gca,'YTick',1:5:size(medianBresh,1))
        set(gca,'YTickLabel',1:5:size(medianBresh,1),'Fontsize',8)
        set(gca,'XTick',1:5:size(medianBresh,1))
        set(gca,'XTickLabel',1:5:size(medianBresh,1),'Fontsize',8)
        ylabel('Channels');
        xlabel('Channels');
        axis square;
        set(bh,'uicontextmenu',hh);
        nameG1=Group(1).fileslist(1).group_name;        
        B2 = reshape(B,sqrt(size(B,1)),sqrt(size(B,1)),size(B,2));

        title([s.statname ' of ', statfuncname, ' for ''', regexprep(nameG1,'_',''),''''],'fontweight','bold','fontsize',12)
        if ~(isempty(C) || isempty(p))
        C2 = reshape(C,sqrt(size(C,1)),sqrt(size(C,1)),size(C,2));
        p2 = reshape(p,sqrt(size(p,2)),sqrt(size(p,2)),size(p,1));
        uimenu(hh,'label','plot channel','callback',{@nbt_coord2plot_group,C2,p2,[],unit,B2});% needs stat_results input
        uimenu(hh,'label','select chan from prompt','callback',{@nbt_biom2plot_group,C2,p2,[],unit,B2});
        end
    end

 
 end