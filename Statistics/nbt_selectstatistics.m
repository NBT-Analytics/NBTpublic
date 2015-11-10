% nbt_selectstatistics - Compute statistics within a group, allows you to specify a defined group 
%
% Usage:
%   statdata = nbt_selectstatistics(SignalInfo, c1,c2)
%
% Inputs:
%   SignalInfo
%   c1 contains biomarker data for each subject, it's a matrix of dimension
%   n_biomarkersxn_subjects
%   
%   c2 contains biomarker data for each subject, it's a matrix of dimension
%   n_biomarkersxn_subjects
%
% Outputs:
%   statdata   is a struct containing
%             statdata.test % test name
%             statdata.statistic % statisticcs (ie. @nanmean)
%             statdata.func % statistic function (i.e. @ttest)
%             statdata.p % p-values
%             statdata.C % confidence interval
%
% Example:
%
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

function statdata = nbt_selectstatistics(varargin);
P=varargin;
nargs=length(P);

SignalInfo = P{1};
if (nargs<2 || isempty(P{2})) 
    error('Select biomarkers')
else
    c1 = P{2}; 
end;
if (nargs<3 || isempty(P{3})) 
    c2 = [];
else
    c2 = P{3}; 
end;

if (nargs<4 || isempty(P{4})) 
    conditions = [];
else
    conditions = P{4}; 
end;

% --- insert test name here

stat{1} ='Lilliefors test';
stat{2} ='Student paired t-test';
stat{3} ='Wilcoxon signed rank test';
stat{4} ='Two-sample t-test';
stat{5} ='Wilcoxon rank sum test';
stat{6} = 'Shapiro-Wilk test';
statdata = []; 
StatisticsSelection = figure('Units','pixels', 'name','List of Statistic tests' ,'numbertitle','off','Position',[390.0000  456.7500  450  88.5000], ...
        'MenuBar','none','NextPlot','new','Resize','off','Visible','off');

listBox = uicontrol(StatisticsSelection,'Style','listbox','Units','characters',...
        'Position',[4 1 110 6],...
        'BackgroundColor','white',...
        'Max',10,'Min',1, 'String', stat,'Value',[],'callback',@selectstat,'Visible','off');
if nargs == 5
    testnum = P{5};
    set(listBox,'Value',testnum)
    selectstat
else
    set(StatisticsSelection, 'Visible', 'on')
    set(listBox, 'Visible', 'on')
end
   
% --- callback function
function selectstat(src,evt)
   vars = get(listBox,'String');
   var_index = get(listBox,'Value');
   switch var_index
       case 1
            statistic=@nbt_cdfcalc_modified;
            statfunc = @lillietest;
            statfuncname='lillietest';
            statname='nbt_cdfcalc_modified';
            
            statdata.test = vars(var_index);% test name
            statdata.statistic = statistic;
            statdata.func = statfunc;
            
            number_of_biomarkers=size(c1,1);
            if isempty(conditions)
                for i=1:number_of_biomarkers
                    try
                        [h(i),p_biomarkers(i),KS(i),critval(i)]=statfunc(c1(i,:));%,0.05,'norm',1e-4);
                    catch
                        h(i) = nan;
                        p_biomarkers(i) = nan;
                        KS(i) = nan;
                        critval(i) = nan;
                    end
                end
                for i = 1:size(c1,1)
                    cdf1(i).cdf=statistic(c1(i,:)); %mean / median per biomarker
                end
                
                statdata.c1 = c1;
                statdata.cdf1 = cdf1; 
                statdata.h = h; 
                statdata.p = p_biomarkers;
                statdata.KS = KS;
                statdata.critval = critval;
                
                if number_of_biomarkers == 129
                    number_of_subjects = size(c1,2);
                    for i=1:number_of_subjects 
                        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                    end
                    for i=1:size(c1_regions,1)
                        [h_regions(i),p_regions(i),KS_regions(i),critval_regions(i)]=statfunc(c1_regions(i,:));%,0.05,'norm',1e-4);
                    end
                    for i = 1:size(c1_regions,1)
                        cdf_c1_regions(i).cdf=statistic(c1_regions(i,:)); %mean / median per region
                    end
                    
                    statdata.c1_regions = c1_regions;
                    statdata.cdf_c1_regions = cdf_c1_regions;
                    statdata.h_regions = h_regions;
                    statdata.p_regions = p_regions;
                    statdata.KS_regions = KS_regions;
                    statdata.critval_regions = critval_regions;
                end
              
            else
                diffC2C1= c2 - c1;
                for i=1:number_of_biomarkers
                    try
                        [h(i),p_biomarkers(i),KS(i),critval(i)]=statfunc(diffC2C1(i,:));%,0.05,'norm',1e-4);
                    catch
                        h(i) = nan;
                        p_biomarkers(i) = nan;
                        KS(i) = nan;
                        critval(i) = nan;
                    end
                end
                for i = 1:size(c1,1)
                    cdf1(i).cdf=statistic(c1(i,:)); %mean / median per biomarker
                    cdf2(i).cdf=statistic(c2(i,:));
                end
                
                cdf1=statistic(c1,2); %mean / median per channel condition 1
                cdf2=statistic(c2,2); %mean / median per channel condition 2
                
                statdata.diffC2C1 = diffC2C1;
                statdata.c1 = c1;
                statdata.c2 = c2;
                statdata.cdf1 = cdf1;
                statdata.cdf2 = cdf2;
                statdata.h = h;
                statdata.p = p_biomarkers;
                statdata.KS= KS;
                statdata.critval = critval;
                
               
                if number_of_biomarkers == 129
                    number_of_subjects = size(c1,2);
                    for i=1:number_of_subjects 
                        diff_regions(:,i)=nbt_get_regions(diffC2C1(:,i),[],SignalInfo);
                        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                        c2_regions(:,i) = nbt_get_regions(c2(:,i),[],SignalInfo);
                    end
                    for i=1:size(c1_regions,1)
                        [h_regions(i),p_regions(i),KS_regions(i), critval_regions(i) ]=statfunc(diff_regions(i,:));%,0.05,'norm',1e-4);
                        [h1(i),p1(i),KS1(i), critval1_regions(i)]=statfunc(c1_regions(i,:));%,0.05,'norm',1e-4);
                        [h2(i),p2(i),KS2(i), critval2_regions(i)]=statfunc(c2_regions(i,:));%,0.05,'norm',1e-4);
                    end
                    for i = 1:size(c1_regions,1)
                        cdf_c1_regions(i).cdf=statistic(c1_regions(i,:)); %mean / median per region 1
                        cdf_c2_regions(i).cdf=statistic(c2_regions(i,:));%mean / median per region condition 2
                    end
                
                    statdata.c1_regions = c1_regions;
                    statdata.c2_regions = c2_regions;
                    statdata.diff_regions = diff_regions;
                    statdata.cdf_c1_regions = cdf_c1_regions;
                    statdata.cdf_c2_regions = cdf_c2_regions;
                    statdata.h_regions = h_regions;
                    statdata.p_regions = p_regions;
                    statdata.KS_regions = KS_regions;
                    statdata.critval_regions = critval_regions;
                    statdata.h1 = h1;
                    statdata.h2 = h2;
                    statdata.p1 = p1;
                    statdata.p2 = p2;
                    statdata.KS1 = KS1;
                    statdata.KS2 = KS2;
                    statdata.critval1_regions = critval1_regions;
                    statdata.critval2_regions = critval2_regions;
                end
                
            end
            assignin('caller','statdata', statdata);
            close(StatisticsSelection)
            
       case 2
            statistic=@nanmean;
            statfunc = @ttest;
            statfuncname='ttest';
            statname='mean';
            
            statdata.test = vars(var_index);% test name
            statdata.statistic = statistic;
            statdata.func = statfunc;
            
          
            
            number_of_biomarkers=size(c1,1);
            if isempty(conditions)
                for i=1:number_of_biomarkers
                    try
                        [h(i),p_biomarkers(i),C(i,:)]=statfunc(c1(i,:),c2(i,:));
                    catch
                        h(i) = nan;
                        p_biomarkers(i) = nan;
                        C(i,:) = [nan nan]';
                    end
                end
                meanc1=statistic(c1,2); %mean / median per biomarker
                meanc2=statistic(c1,2); %mean / median per biomarker
                
                statdata.c1 = c1;
                statdata.meanc1 = meanc1; 
                statdata.c2 = c2;
                statdata.meanc2 = meanc2;
                 statdata.Diffc2c1 = meanc2-meanc1;
                statdata.h = h; 
                statdata.p = p_biomarkers;
                statdata.C = C;
                
                if number_of_biomarkers == 129
                number_of_subjects = size(c1,2);
                % biomarker per region
                    for i=1:number_of_subjects 
                        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                    end
                    for i=1:size(c1_regions,1)
                        [h_regions(i),p_regions(i),C_regions(i,:)]=statfunc(c1_regions(i,:));
                    end
                mean_c1_regions=statistic(c1_regions,2); %mean / median per region
                
                statdata.c1_regions = c1_regions;
                statdata.mean_c1_regions = mean_c1_regions;
                statdata.h_regions = h_regions;
                statdata.p_regions = p_regions;
                statdata.C_regions = C_regions;
                
                end
            else
                diffC2C1= c2 - c1;
                for i=1:number_of_biomarkers
                    try
                        [h(i),p_biomarkers(i),C(i,:)]=statfunc(diffC2C1(i,:));
                    catch
                        h(i) = nan;
                        p_biomarkers(i) = nan;
                        C(i,:) = [nan nan]';
                    end
                end
                
                meanc1=statistic(c1,2); %mean / median per channel condition 1
                meanc2=statistic(c2,2); %mean / median per channel condition 2
                
                statdata.diffC2C1 = diffC2C1;
                statdata.c1 = c1;
                statdata.c2 = c2;
                statdata.meanc1 = meanc1;
                statdata.meanc2 = meanc2;
               
                statdata.h = h;
                statdata.p = p_biomarkers;
                statdata.C = C;
                
                if number_of_biomarkers == 129
                    number_of_subjects = size(c1,2);
                    for i=1:number_of_subjects 
                        diff_regions(:,i)=nbt_get_regions(diffC2C1(:,i),[],SignalInfo);
                        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                        c2_regions(:,i) = nbt_get_regions(c2(:,i),[],SignalInfo);
                    end
                    for i=1:size(c1_regions,1)
                        [h_regions(i),p_regions(i),C_regions(i,:)]=statfunc(diff_regions(i,:));
                        [h1(i),p1(i),C1(i,:)]=statfunc(c1_regions(i,:));
                        [h2(i),p2(i),C2(i,:)]=statfunc(c2_regions(i,:));
                    end
                    mean_c1_regions=statistic(c1_regions,2); %mean / median per region condition 1
                    mean_c2_regions=statistic(c2_regions,2);%mean / median per region condition 2
                    
                    statdata.c1_regions = c1_regions;
                    statdata.c2_regions = c2_regions;
                    statdata.diff_regions = diff_regions;
                    statdata.mean_c1_regions = mean_c1_regions;
                    statdata.mean_c2_regions = mean_c2_regions;
                    statdata.h_regions = h_regions;
                    statdata.p_regions = p_regions;
                    statdata.C_regions = C_regions;
                    statdata.h1 = h1;
                    statdata.h2 = h2;
                    statdata.p1 = p1;
                    statdata.p2 = p2;
                    statdata.C1 = C1;
                    statdata.C2 = C2;
                    
                end
            end
            assignin('caller','statdata', statdata);
            close(StatisticsSelection)
            
       case 3
            statistic=@nanmedian;
            statfunc = @signrank;
            statfuncname='signrank';
            statname='median';
            
            statdata.test = vars(var_index);% test name
            statdata.statistic = statistic;
            statdata.func = statfunc;
            
            number_of_biomarkers=size(c1,1);
            if isempty(conditions)
                for i=1:number_of_biomarkers
                    try
                        [p_biomarkers(i),h(i)]=statfunc(c1(i,:));
                        C(i,:)=bootci(1000,@nanmedian,c1(i,:));
                    catch
                        p_biomarkers(i) = nan;
                        C(i,:) = nan;
                    end
                end
                medianc1 = statistic(c1,2); %mean / median per biomarker
                
                statdata.c1 = c1;
                statdata.medianc1 = medianc1; 
                statdata.p = p_biomarkers;
                statdata.C = C;
                statdata.h = h;
                
                if number_of_biomarkers == 129
                    number_of_subjects = size(c1,2);
                    for i=1:number_of_subjects 
                        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                    end
                    for i=1:size(c1_regions,1)
                        [p_regions(i), h_regions(i)]=statfunc(c1_regions(i,:));
                        C_regions(i,:)=bootci(1000,statistic,c1_regions(i,:));
                    end
                    median_c1_regions=statistic(c1_regions,2); %mean / median per region
                
                    statdata.c1_regions = c1_regions;
                    statdata.h_regions = h_regions;
                    statdata.median_c1_regions = median_c1_regions;
                    statdata.p_regions = p_regions;
                    statdata.C_regions = C_regions;
                    
                end
                
             else
                diffC2C1= c2 - c1;
                for i=1:number_of_biomarkers
                    try
                        [p_biomarkers(i), h(i)]=statfunc(diffC2C1(i,:));
                        C(i,:)=bootci(1000,@nanmedian,diffC2C1(i,:));
                    catch
                        p_biomarkers(i) = nan;
                        C(i,:) = [nan nan]';
                    end
                end
                medianc1=statistic(c1,2); %mean / median per channel condition 1
                medianc2=statistic(c2,2); %mean / median per channel condition 2
                
                statdata.diffC2C1 = diffC2C1;
                statdata.c1 = c1;
                statdata.c2 = c2;
                statdata.medianc1 = medianc1;
                statdata.medianc2 = medianc2;
                statdata.p = p_biomarkers;
                statdata.h = h;
                statdata.C = C;
                
                if number_of_biomarkers == 129
                    number_of_subjects = size(c1,2);
                    for i=1:number_of_subjects 
                        diff_regions(:,i)=nbt_get_regions(diffC2C1(:,i),[],SignalInfo);
                        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                        c2_regions(:,i) = nbt_get_regions(c2(:,i),[],SignalInfo);
                    end
                    for i=1:size(c1_regions,1)
                        [p_regions(i),h_regions(i)]=statfunc(diff_regions(i,:));
                        C_regions(i,:)=bootci(1000,statistic,diff_regions(i,:));
                        C1(i,:)=bootci(1000,statistic,c1_regions(i,:));
                        C2(i,:)=bootci(1000,statistic,c2_regions(i,:));
                    end
                    median_c1_regions=statistic(c1_regions,2); %mean / median per region condition 1
                    median_c2_regions=statistic(c2_regions,2);%mean / median per region condition 2
                    
                    statdata.c1_regions = c1_regions;
                    statdata.c2_regions = c2_regions;
                    statdata.diff_regions = diff_regions;
                    statdata.median_c1_regions = median_c1_regions;
                    statdata.median_c2_regions = median_c2_regions;
                    statdata.p_regions = p_regions;
                    statdata.h_regions = h_regions;
                    statdata.C_regions = C_regions;
                    statdata.C1 = C1;
                    statdata.C2 = C2;
                end
                
            end
            assignin('caller','statdata', statdata);
            close(StatisticsSelection)
        
        case 4
            if isempty(c2)
                error('Indicate Biomarkers for the second group')
            else
                statistic=@nanmean;
                statfunc = @ttest2;
                statfuncname='ttest2';
                statname='mean';
                
                statdata.test = vars(var_index);% test name
                statdata.statistic = statistic;
                statdata.func = statfunc;
                
                number_of_biomarkers=size(c1,1);
                for i=1:number_of_biomarkers
                    try
                        [h(i),p_biomarkers(i),C(i,:)]=statfunc(c1(i,:),c2(i,:));
                    catch
                        h(i) = nan;
                        p_biomarkers(i) = nan;
                        C(i,:) = nan;
                    end
                end
                meanc1=statistic(c1,2); %mean / median per biomarker group 1
                meanc2=statistic(c2,2); %mean / median per biomarker group 2
                Diffc2c1=meanc2-meanc1;
                
                statdata.c1 = c1;
                statdata.c2 = c2;
                statdata.meanc1 = meanc1; 
                statdata.meanc2 = meanc2;
                statdata.h = h;
                statdata.p = p_biomarkers;
                statdata.C = C;
                statdata.Diffc2c1 = Diffc2c1;
                
            if number_of_biomarkers == 129
                for i=1:size(c1,2) % nr subjects
                    c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                end
                for i=1:size(c2,2) % nr subjects
                    c2_regions(:,i) = nbt_get_regions(c2(:,i),[],SignalInfo);
                end
                % test per region
                for i=1:size(c1_regions,1)
                    [h_regions(i),p_regions(i),C_regions(i,:)]=statfunc(c1_regions(i,:),c2_regions(i,:));
                    [h1(i),p1(i),C1(i,:)]=ttest(c1_regions(i,:));
                    [h2(i),p2(i),C2(i,:)]=ttest(c2_regions(i,:));
                end
                
                %  get means/medians per group
                mean_c1_regions=statistic(c1_regions,2);% mean / median per region group 1
                mean_c2_regions=statistic(c2_regions,2);% mean / median per region group 2
                
                statdata.c1_regions = c1_regions;
                statdata.c2_regions = c2_regions;
                statdata.mean_c1_regions = mean_c1_regions;
                statdata.mean_c2_regions = mean_c2_regions;
                statdata.h_regions = h_regions;
                statdata.p_regions = p_regions;
                statdata.C_regions = C_regions;
                statdata.h1 = h1;
                statdata.h2 = h2;
                statdata.p1 = p1;
                statdata.p2 = p2;
                statdata.C1 = C1;
                statdata.C2 = C2;
                
            end

            assignin('caller','statdata', statdata);
            close(StatisticsSelection)
            end
            
        case 5
            if isempty(c2)
                error('Indicate Biomarkers for the second group')
            else
                statistic=@nanmedian;
                statfunc = @ranksum;
                statfuncname='ranksum';
                statname='median';

                statdata.test = vars(var_index);% test name
                statdata.statistic = statistic;
                statdata.func = statfunc;
                
                number_of_biomarkers=size(c1,1);
                for i=1:number_of_biomarkers
                        try
                            [p_biomarkers(i),h(i)]=statfunc(c1(i,:),c2(i,:));
                            C(i,:)=bootci(1000,{@median_diff,c2(i,:),c1(i,:)});
                        catch
                            p_biomarkers(i) = nan;  
                            C(i,:) = nan;
                        end
                end
                medianc1=statistic(c1,2); %mean / median per biomarker group 1
                medianc2=statistic(c2,2); %mean / median per biomarker group 2
                Diffc2c1=medianc2-medianc1;
                
                statdata.c1 = c1;
                statdata.c2 = c2;
                statdata.medianc1 = medianc1; 
                statdata.medianc2 = medianc2;
                statdata.p = p_biomarkers;
                statdata.h = h;
                statdata.C = C;
                statdata.Diffc2c1 = Diffc2c1;
                
            if number_of_biomarkers == 129
                for i=1:size(c1,2) % nr subjects
                    c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                end
                for i=1:size(c2,2) % nr subjects
                    c2_regions(:,i) = nbt_get_regions(c2(:,i),[],SignalInfo);
                end
                % test per region
                for i=1:size(c1_regions,1)
                    [p_regions(i), h_regions(i)]=statfunc(c1_regions(i,:),c2_regions(i,:)); 
                    C_regions(i,:)=bootci(1000,{@median_diff,c1_regions(i,:),c2_regions(i,:)});
                    C1(i,:)=bootci(1000,statistic,c1_regions(i,:));
                    C2(i,:)=bootci(1000,statistic,c2_regions(i,:));
                end
                
                %  get means/medians per group
                median_c1_regions=statistic(c1_regions,2);% mean / median per region group 1
                median_c2_regions=statistic(c2_regions,2);% mean / median per region group 2
                
                statdata.c1_regions = c1_regions;
                statdata.c2_regions = c2_regions;
                statdata.median_c1_regions = median_c1_regions;
                statdata.median_c2_regions = median_c2_regions;
                statdata.p_regions = p_regions;
                statdata.h_regions =h_regions;
                statdata.C_regions = C_regions;
                statdata.C1 = C1;
                statdata.C2 = C2;
                
            end
            
            assignin('caller','statdata', statdata);
            close(StatisticsSelection)
            
            end
            
            
       case 6
            
            statfunc = @swtest;
            statfuncname='swtest';
            
            statdata.test = vars(var_index);% test name
            statdata.func = statfunc;
            
            number_of_biomarkers=size(c1,1);
            if isempty(conditions)
                for i=1:number_of_biomarkers
                    try
                        [h(i),p_biomarkers(i),W(i)]=statfunc(c1(i,:));%,0.05,'norm',1e-4);
                    catch
                        h(i) = nan;
                        p_biomarkers(i) = nan;
                        W(i) = nan;
                    end
                end
                statdata.c1 = c1;
                statdata.h = h; 
                statdata.p = p_biomarkers;
                statdata.W = W;
                if number_of_biomarkers == 129
                    number_of_subjects = size(c1,2);
                    for i=1:number_of_subjects 
                        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                    end
                    for i=1:size(c1_regions,1)
                        [h_regions(i),p_regions(i),W_regions(i)]=statfunc(c1_regions(i,:));%,0.05,'norm',1e-4);
                    end
                    
                    statdata.c1_regions = c1_regions;
                    statdata.h_regions = h_regions;
                    statdata.p_regions = p_regions;
                    statdata.W_regions = W_regions;
                end
              
            else
                diffC2C1= c2 - c1;
                for i=1:number_of_biomarkers
                    try
                        [h(i),p_biomarkers(i),W(i)]=statfunc(diffC2C1(i,:));%,0.05,'norm',1e-4);
                    catch
                        h(i) = nan;
                        p_biomarkers(i) = nan;
                        W(i) = nan;
                    end
                end
                
                statdata.diffC2C1 = diffC2C1;
                statdata.c1 = c1;
                statdata.c2 = c2;
                statdata.h = h;
                statdata.p = p_biomarkers;
                statdata.W = W;
               
                if number_of_biomarkers == 129
                    number_of_subjects = size(c1,2);
                    for i=1:number_of_subjects 
                        diff_regions(:,i)=nbt_get_regions(diffC2C1(:,i),[],SignalInfo);
                        c1_regions(:,i) = nbt_get_regions(c1(:,i),[],SignalInfo);
                        c2_regions(:,i) = nbt_get_regions(c2(:,i),[],SignalInfo);
                    end
                    for i=1:size(c1_regions,1)
                        [h_regions(i),p_regions(i),W_regions(i)]=statfunc(diff_regions(i,:));%,0.05,'norm',1e-4);
                        [h1(i),p1(i),W1(i)]=statfunc(c1_regions(i,:));%,0.05,'norm',1e-4);
                        [h2(i),p2(i),W2(i)]=statfunc(c2_regions(i,:));%,0.05,'norm',1e-4);
                    end
                    
                    statdata.c1_regions = c1_regions;
                    statdata.c2_regions = c2_regions;
                    statdata.diff_regions = diff_regions;
                    statdata.h_regions = h_regions;
                    statdata.p_regions = p_regions;
                    statdata.W_regions = W_regions;
                    statdata.h1 = h1;
                    statdata.h2 = h2;
                    statdata.p1 = p1;
                    statdata.p2 = p2;
                    statdata.W1 = W1;
                    statdata.W2 = W2;
                end
                
            end
            assignin('caller','statdata', statdata);
            close(StatisticsSelection)
      % --- add test specifics here
   end
end
function[d]=median_diff(M,N)
    
        m1=nanmedian(M);
        m2=nanmedian(N);
        d=m2-m1;
end
end
    