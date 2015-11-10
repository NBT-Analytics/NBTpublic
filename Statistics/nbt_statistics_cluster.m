% Compute and visualize statistics of a biomarker within a group of
% NBT signals.
%
% Usage: nbt_statistics_group(directory,biomarker,statistic,plotting)
%
% Inputs:
% directory = path to directoy with NBT files
% biomarker = name of biomarker, as it is written in the analysis file
% statistic = 'mean' (default) or 'median'
% plotting = 0 (default) or 1. If plotting =1, a pdf will be generated with a plot of the statistics
%
% For example:
% nbt_statistics_group('C:\NBT','amplitude_1_4_Hz.Channels','median',1)
%
% References:
%
% See also:
% nbt_statistics_conditions, nbt_statistics_groups

%------------------------------------------------------------------------------------
% Originally created by Rick Jansen (2010), see NBT website for current email
% address
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
% ---------------------------------------------------------------------------------------
function nbt_statistics_cluster(varargin)

%% assign fields

fontsize=8;
P=varargin;
nargs=length(P);

if (nargs<1 | isempty(P{1}))[path]=uigetdir([],'select folder with NBT Signals'); else path = P{1}; end;

if (nargs<2 | isempty(P{2}))
    % get biomarkers
    biomarker=[];
    d=dir(path);
    for i=1:length(d)
        if ~isempty(findstr('analysis',d(i).name))
            [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path,'/', d(i).name]);
            break
        end
    end
    [selection,ok]=listdlg('liststring',biomarker_objects, 'ListSize',[250 300],'PromptString','Select biomarker objects');
    for i=1:length(selection)
        biomarker_object{i}=biomarker_objects{selection(i)};
        [selection1,ok]=listdlg('liststring',biomarkers{selection(i)}, 'ListSize',[250 300],'PromptString',['Select biomarker in ',biomarker_object{i}]);
        for j=1:length(selection1)
            biomarker=[biomarker strcat(biomarker_object,'.',biomarkers{selection(i)}(selection1(j)))];
        end
    end
else biomarker = P{2};
end

if (nargs<4 | isempty(P{4})) plotting=0; else plotting = P{4}; end;


SignalInfo=nbt_getInfoObject(path,'Signal'); % get one Info file for locations channels, in case of EEG data

disp(' ')
disp('Command window code:')
disp(['nbt_statistics_cluster(',char(39),path,char(39),',',num2str(plotting),');'])
disp(' ')

%
 %% get biomarkers from analysis files
%
% [c1,s1,p1,unit]=nbt_load_analysis(path,[],biomarker,@nbt_get_biomarker,[],[],[]);
% c1=c1';
% number_of_biomarkers=size(c1,1);
% number_of_subjects=size(c1,2);
%
% %  c1 contains the biomarkers, subjects are
% %  in columns,biomarkers (for example channels) are in rows
%
% % test per biomarker
% for i=1:number_of_biomarkers
%     if strcmp(statfuncname,'ttest')
%         [h(i),p_biomarkers(i),ci(i,:)]=statfunc(c1(i,:));
%     end
%     if strcmp(statfuncname,'signrank')
%         p_biomarkers(i)=statfunc(c1(i,:));
%     end
% end
