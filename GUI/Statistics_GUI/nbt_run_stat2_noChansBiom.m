% nbt_run_stat2_noChansBiom - computes the select statistics for two
% groups or conditions and provides visualization of the results
%
% Usage:
%  [s] =
%  nbt_run_stat2_noChansBiom(Group1,Group2,B1,B2,s,biom,unit)
%
% Inputs:
%   Group1,
%   Group2,
%   B1,
%   B2
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
%  nbt_plot_2conditions_topo
  
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

function  [s] = nbt_run_stat2_noChansBiom(Group1,Group2,B1,B2,s,biom,unit)
statistic=s.statistic;
statfunc =s.statfunc;
statfuncname=s.statfuncname;
statname=s.statname;
nchans_o_nregs = size(B1,1);
s.biom_name = biom;
s.group_ind=evalin('caller','group_ind');
s.group_name=evalin('caller','group_name');

if strcmp(char(statfunc),'nanmedian')
    warning('This test is not design for multiple groups');
elseif strcmp(char(statfunc),'lillietest')
    warning('This test is not design for multiple groups');
elseif strcmp(char(statfunc),'swtest')
    warning('This test is not design for multiple groups');
elseif strcmp(char(statfunc),'ttest')
    try
    for i = 1:nchans_o_nregs
        [h,p(i),C(i,:),stats] = ttest(B1(i,:),B2(i,:));
        statvalues(i) = stats.tstat;
    end    
    s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,[],unit);
    catch
        warning('The two groups do not have the same number of subjects')
    end
elseif strcmp(char(statfunc),'signrank')
    try
    B = B2-B1;
    for i = 1:nchans_o_nregs
        [p(i),h,stats] = signrank(B1(i,:),B2(i,:));
        C(i,:)=bootci(1000,statistic,B(i,:));
        statvalues(i) = stats.signedrank;
    end
        if sqrt(size(B1,1)) == length(Group1.chansregs.chanloc)
            nbt_2array2squaremat(Group1,Group2,B1,B2,s,biom,C,p)
        else
            s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,[],unit);
        end
    catch
        warning('The two groups do not have the same number of subjects')
    end
elseif strcmp(char(statfunc),'ttest2')
    for i = 1:nchans_o_nregs
        [h,p(i),C(i,:),stats] = ttest2(B1(i,:),B2(i,:));
        statvalues(i) = stats.tstat;
    end  
     if sqrt(size(B1,1)) == length(Group1.chansregs.chanloc)
        nbt_2array2squaremat(Group1,Group2,B1,B2,s,biom,C,p)
    else
        s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,[],unit);
    end
elseif strcmp(char(statfunc),'ranksum')
     for i = 1:nchans_o_nregs
        [p(i),h,stats] = ranksum(B1(i,:),B2(i,:));
        try
             C(i,:)=bootci(1000,{@median_diff,B1(i,:),B2(i,:)});
        catch
            warning('Confidence Interval computed with bootci requires same sample size')
        end
        statvalues(i) = stats.ranksum;
     end
    if sqrt(size(B1,1)) == length(Group1.chansregs.chanloc)
        nbt_2array2squaremat(Group1,Group2,B1,B2,s,biom,C,p)
    else
        s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,[],unit);
    end
     
elseif strcmp(char(statfunc),'nbt_perm_group_diff')
    if strcmp(char(statname),'mean')
        for i = 1:nchans_o_nregs
            [p(i)] = nbt_perm_group_diff(B1(i,:),B2(i,:),'mean',5000,0);
        end
    elseif strcmp(char(statname),'median')
        for i = 1:nchans_o_nregs
            [p(i)] = nbt_perm_group_diff(B1(i,:),B2(i,:),'median',5000,0);
        end
    end
%     s.C = C;
    s.p = p;
    s.c1 = B1;
    s.c2 = B2;
    s.meanc1 = statistic(B1,2);
    s.meanc2 = statistic(B2,2);
    s.diff_biom = B2-B1;
    s.diff_mean_or_med_biom = s.meanc2-s.meanc1;
    
elseif strcmp(char(statfunc),'nbt_perm_corr')
    for i = 1:nchans_o_nregs
        [p(i)] = nbt_perm_corr(B1(i,:),B2(i,:),[],5000,0);
    end

    for i = 1:nchans_o_nregs
        corrB1(i) = corr(B1(i,:)','rows','pairwise');
        corrB2(i) = corr(B2(i,:)','rows','pairwise');
    end
    %   s.C = C;
    s.p = p;
    s.c1 = B1;
    s.c2 = B2;
    s.meanc1 =corrB1; %correlation
    s.meanc2 =corrB2; %correlation
    s.diff_biom = B2-B1;
    s.diff_mean_or_med_biom = s.meanc2-s.meanc1;% difference of correlation coeff
elseif strcmp(char(statfunc),'zscore')
    dim = 2;
    sigma = nanstd(B2,1,dim);
    mu = nanmean(B2,dim);
    sigma(sigma==0) = 1;
    z = bsxfun(@minus,B1, mu);
    z = bsxfun(@rdivide, z, sigma);
    s.mu=mu;
    s.sigma=sigma;
    s.vals=z;
end

function[d]=median_diff(M,N)
        m1=nanmedian(M);
        m2=nanmedian(N);
        d=m2-m1;
end


%-------------------------------------------------
     function s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,regions,unit)
            chanloc = Group1.chansregs.chanloc;
            unit = unit;
            s.C = C;
            s.p = p;
            s.c1 = B1;
            s.c2 = B2;
            s.unit = unit;
            s.meanc1 = statistic(B1,2);
            s.meanc2 = statistic(B2,2);
            if size(B1,2) == size(B2,2)
            s.diff_biom = B2-B1;
            end
            s.diff_mean_or_med_biom = s.meanc2-s.meanc1;
            % you can comment the next line, because you can also plot same
            % data using the p-value max figure
%             nbt_plot_2conditions_topo(Group1,Group2,chanloc,s,unit,biom,[]);
     end
 %------------------------------------------------
  %%
%     function nbt_coord2plot_group(HOBJ,EVENTDATA,C,p,regions,unit,B2);
%         pos_cursor_unitfig = get(gca,'currentpoint');
%         chan_or_reg = round(pos_cursor_unitfig(1,2));
%         biomarker = round(pos_cursor_unitfig(1,1));
%         if ~isempty(C) && ~isempty(p)
%             C=squeeze(C(biomarker,:,:));
%             p=squeeze(p(biomarker,:,:));
%         end
% %         nbt_plot_group(C,p,regions,unit);
% %         nbt_plot_group(Group,B,C,p,statistic,statfuncname,biom,[],unit);
% 
%         nbt_plot_group(Group,squeeze(B2(biomarker,:,:)),C,p,statistic,statfuncname,strcat(biom,' (',int2str(biomarker),', : )'),regions,unit);
% % disp('Testing');
%     end
%------------------------------------------------
%     function nbt_biom2plot_group(HOBJ,EVENTDATA,C,p,regions,unit,B2);
%         biomarker = str2num(cell2mat(inputdlg('Which channel do you want to plot?: ' )));
%         if ~isempty(C) && ~isempty(p)
%             C=squeeze(C(biomarker,:,:));
%             p=squeeze(p(biomarker,:,:));
%         end
%         nbt_plot_group(Group,squeeze(B2(biomarker,:,:)),C,p,statistic,statfuncname,strcat(biom,' (',int2str(biomarker),', : )'),regions,unit);
%     end
%------------------------------------------------
    function nbt_2array2squaremat(Group1,Group2,B1,B2,s,biom,C,p)
%         medianB = s.statistic((B1-B2),2)';
%         medianBresh = reshape(medianB,sqrt(size(B1,1)),sqrt(size(B1,1)));
%         bh=imagesc(medianBresh);
        p2 = log10(reshape(p,sqrt(size(p,2)),sqrt(size(p,2)),size(p,1)));
        bh=imagesc(p2);
%         hh=uicontextmenu;
%         hh2 = uicontextmenu;
%         colorbar('off')
%         minPValue=min(min(p2));
%         maxPValue=max(max(p2));
        coolWarm = load('nbt_CoolWarm.mat','coolWarm');
        coolWarm = coolWarm.coolWarm;
        colormap([0,0,0;coolWarm]);
        cbh = colorbar('EastOutside');
        minPValue = -2.6;%min(zdata(:));% Plot log10(P-Values) to trick colour bar
        maxPValue = 0;%max(zdata(:));
        caxis([minPValue maxPValue])
        set(cbh,'YTick',[-2 -1.3010 -1 0])
        set(cbh,'YTicklabel',[0.01 0.05 0.1 1]) %(log scale)
        set(cbh,'XTick',[],'XTickLabel','')
%     set(get(cbh,'title'),'String','p-values','fontsize',8,'fontweight','b
%     old');
        DeltaC = (maxPValue-minPValue)/20;
%         pos_a = get(gca,'Position');
%     %     pos = get(cbh,'Position');
%         set(cbh,'Position',[1.5*pos_a(1)+pos_a(3) pos_a(2)+pos_a(4)/3 0.01 0.3 ])
%         Pos=get(cbh,'position'); 
        set(cbh,'units','normalized'); 
        bioms_name={biom};
        set(gca,'YTick',1:5:size(p2,1))
        set(gca,'YTickLabel',1:5:size(p2,1),'Fontsize',8)
        set(gca,'XTick',1:5:size(p2,1))
        set(gca,'XTickLabel',1:5:size(p2,1),'Fontsize',8)
        ylabel('Channels');
        xlabel('Channels');
        axis square;
%         set(bh,'uicontextmenu',hh);
        nameG1=Group1.selection.group_name;        
        nameG2=Group2.selection.group_name; 
%         B2 = reshape(B2,sqrt(size(B2,1)),sqrt(size(B2,1)),size(B2,2));
%         B1 = reshape(B1,sqrt(size(B2,1)),sqrt(size(B2,1)),size(B2,2));
        title(['P-values for', statfuncname, ' between ''', regexprep(nameG1,'_',''),' and ', regexprep(nameG2,'_',''),''''],'fontweight','bold','fontsize',12)
%         if ~(isempty(C) || isempty(p))
%         C2 = reshape(C,sqrt(size(C,1)),sqrt(size(C,1)),size(C,2));
%         p2 = reshape(p,sqrt(size(p,2)),sqrt(size(p,2)),size(p,1));
%         uimenu(hh,'label','plot channel','callback',{@nbt_coord2plot_group,C2,p2,[],unit,B2});% needs stat_results input
%         uimenu(hh,'label','select chan from prompt','callback',{@nbt_biom2plot_group,C2,p2,[],unit,B2});
%         end
    end

end