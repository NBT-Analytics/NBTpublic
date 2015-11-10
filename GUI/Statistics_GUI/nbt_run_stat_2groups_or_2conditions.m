% run_stat_2groups_or_2conditions - computes the select statistics for two
% groups or conditions and provides visualization of the results
%
% Usage:
%  [s] =
%  run_stat_2groups_or_2conditions(Group1,Group2,B1,B2,s,biom,regions,unit)
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
%% ChangeLog - see version control log at NBT website for details.
%$ Version 1.1 - 25. Oct 2012: Modified by Piotr Sokol, piotr.a.sokol@gmail.com$
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

function  [s] = nbt_run_stat_2groups_or_2conditions(Group1,Group2,B1,B2,s,biom,regions,unit)
statistic=s.statistic;
statfunc =s.statfunc;
statfuncname=s.statfuncname;
statname=s.statname;
s.group_ind=evalin('caller','group_ind');
s.group_name=evalin('caller','group_name');
nchans_o_nregs = size(B1,1);
s.biom_name = biom;

if strcmp(char(statname),'nanmedian') %this should better be a switch>.
    warning('This test is not design for multiple groups');
elseif strcmp(char(statname),'nanmean')
    warning('This test is not design for multiple groups');
elseif strcmp(char(statname),'dotplotmedian')
    nbt_DotPlot(figure, 0.1, 0.025, 0, @nanmedian, {Group1.selection.group_name; Group2.selection.group_name; 'Biomarker value'},'',B1,1:size(B1,2), 1:size(B1,1), B2, 1:size(B2,2),1:size(B2,1));
elseif strcmp(char(statname),'dotplotmean')
     nbt_DotPlot(figure, 0.1, 0.025, 0, @nanmean, {Group1.selection.group_name; Group2.selection.group_name; 'Biomarker value'},'',B1,1:size(B1,2), 1:size(B1,1), B2, 1:size(B2,2),1:size(B2,1))
elseif strcmp(char(statfunc),'lillietest')
    warning('This test is not design for multiple groups');
elseif strcmp(char(statfunc),'swtest')
    warning('This test is not design for multiple groups');
elseif strcmp(char(statfunc),'ttest')
    
    % make sure the subjects are really paired in the two groups
    try
    n_subjects1 = size(Group1.fileslist,2);
    n_subjects2 = size(Group2.fileslist,2);
        
    if n_subjects1~=n_subjects2
        warning('The two groups do not have the same number of subjects')
        
    else
        for sub = 1:n_subjects1
            dots1 = strfind(Group1.fileslist(1,sub).name,'.');
            dots2 = strfind(Group2.fileslist(1,sub).name,'.');
            subID1 = str2num(Group1.fileslist(1,sub).name(dots1(1)+2:dots1(2)-1));
            subID2 = str2num(Group2.fileslist(1,sub).name(dots2(1)+2:dots2(2)-1));
            if subID1~=subID2 not_matched=1; break
            end
        end
        
        if not_matched
            warning('The subjects are not paired')
        end
    end
    catch
        warning('Something did not work when matching subjects')
    end
        
        for i = 1:nchans_o_nregs
            [h,p(i),C(i,:),stats] = ttest(B1(i,:),B2(i,:));
            statvalues(i) = stats.tstat;
        end
        s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,regions,unit);

elseif strcmp(char(statfunc),'signrank')
    try
        B = B2-B1;
        for i = 1:nchans_o_nregs
            [p(i),h,stats] = signrank(B1(i,:),B2(i,:));
            C(i,:)=bootci(1000,statistic,B(i,:));
            statvalues(i) = stats.signedrank;
        end
        s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,regions,unit);
    catch
        warning('The two groups do not have the same number of subjects')
    end
elseif strcmp(char(statfunc),'ttest2')
    for i = 1:nchans_o_nregs
        [h,p(i),C(i,:),stats] = ttest2(B1(i,:),B2(i,:));
        statvalues(i) = stats.tstat;
    end
    s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,regions,unit);
elseif strcmp(char(statfunc),'ranksum')
    for i = 1:nchans_o_nregs
        [p(i),h,stats] = ranksum(B1(i,:),B2(i,:));
        try
            C(i,:)=bootci(1000,{@median_diff,B1(i,:),B2(i,:)});
        catch
            warning('Confidence Interval computed with bootci requires same sample size')
            C = [];
        end
        statvalues(i) = stats.ranksum;
    end
    
    s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,[],unit);
    
elseif strcmp(char(statfunc),'nbt_permutationtest')
    if strcmp(char(statname),'mean')
        for i = 1:nchans_o_nregs
            [p(i)]=nbt_permutationtest(B1(i,:),B2(i,:),5000,0,@mean);
            try
                C(i,:)=bootci(1000,{@median_diff,B1(i,:),B2(i,:)});
            catch
                warning('Confidence Interval computed with bootci requires same sample size')
                C = [];
            end
        end
        s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,regions,unit);
    elseif strcmp(char(statname),'median')
        for i = 1:nchans_o_nregs
            [p(i)]=nbt_permutationtest(B1(i,:),B2(i,:),5000,0,@median);
            try
                C(i,:)=bootci(1000,{@median_diff,B1(i,:),B2(i,:)});
            catch
                warning('Confidence Interval computed with bootci requires same sample size')
                C = [];
            end
        end
        s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,regions,unit);
    elseif strcmp(char(statname),'pairedmean')
        for i = 1:nchans_o_nregs
            [p(i)]=nbt_permutationtest(B1(i,:),B2(i,:),5000,1,@mean);
            try
                C(i,:)=bootci(1000,{@median_diff,B1(i,:),B2(i,:)});
            catch
                warning('Confidence Interval computed with bootci requires same sample size')
                C = [];
            end
        end
        s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,regions,unit);
    elseif strcmp(char(statname), 'pairedmedian')
        for i = 1:nchans_o_nregs
            [p(i)]=nbt_permutationtest(B1(i,:),B2(i,:),5000,1,@median);
            try
                C(i,:)=bootci(1000,{@median_diff,B1(i,:),B2(i,:)});
            catch
                warning('Confidence Interval computed with bootci requires same sample size')
                C = [];
            end
        end
        s = plot_group(Group1,Group2,B1,B2,C,p,s,biom,regions,unit);
    end
    %     s.C = C;
    s.p = p;
    s.c1 = B1;
    s.c2 = B2;
    s.meanc1 = statistic(B1,2);
    s.meanc2 = statistic(B2,2);
    if size(B1,2) == size(B2,2)
        s.diff_biom = B2-B1;
    end
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
    if size(B1,2) == size(B2,2)
        s.diff_biom = B2-B1;
    end
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
    s.mu1 = nanmean(B1,dim);

% alternative: compute z scores using the mean and std of the whole set {1st group union 2nd group}    
%     dim = 2;
%     B = [B1 B2];
%     sigma = nanstd(B,1,dim);
%     mu = nanmean(B,dim);
%     sigma(sigma==0) = 1;
%     z1 = bsxfun(@minus,B1, mu);
%     z1 = bsxfun(@rdivide, z1, sigma);
%     z2 = bsxfun(@minus,B2, mu);
%     z2 = bsxfun(@rdivide, z2, sigma);    
%     s.mu=mu;
%     s.sigma=sigma;
%     s.vals1=z1;
%     s.vals2=z2;
      
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
        s.statvalues = statvalues;
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
        %             nbt_plot_2conditions_topo(Group1,Group2,chanloc,s,unit,biom,regions);
    end
end