% nbt_stat_group - Compute statistics within a group, allows you to specify a defined group 
%
% Usage:
%   [statdata]=nbt_stat_group
%   or
%   [statdata]=nbt_stat_group(path,biomarkername)
%   or
%   [statdata]=nbt_stat_group(path,biomarkername,selectedcon,groupname)
%    or
%   [statdata]=nbt_stat_group(path,biomarkername,selectedcon,testnumber,groupname,savedir)
%
% Inputs:
%   path
%   biomarkername 'amplitude_13_30_Hz.Channels'
%   groupname used for saving statistics i.e. 'all wk'
%   selectedcon used for defining the group you can specify a condition 
%               it is a cell i.e. {'wk'}
%   testnumber specify a number according to the test you want to perform
%              on the biomarker:
%                 1 ='Lilliefors test';
%                 2 ='Student paired t-test';
%                 3 ='Wilcoxon signed rank test';
%                 4 ='Two-sample t-test';
%                 5 ='Wilcoxon rank sum test';
%                 6 = 'Shapiro-Wilk test';
%   savedir
%
% Outputs:
%   plot   
%
% Example:
%   nbt_stat_group('/Users/Giusi/Documents/NBT/database/ConvertedFiles','amplitude_13_30_Hz')
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


function [statdata]=nbt_stat_group(varargin)

%--- assign fields
P=varargin;
nargs=length(P);
%--- 1. select Folder
if (nargs<1 || isempty(P{1}))
    [path]=uigetdir([],'select folder with NBT Signals'); 
else
    path = P{1}; 
end;
%--- 2. define the group
% per subjects
% per condition
% per project
% per date
d=dir(path);
SelectedFiles = 0;
assignin('base','SelectedFiles',SelectedFiles);
if nargs >= 3 && ~isempty(P{3})
    selectedcon = P{3};% must be cell i.e {'ERC1'};
    nbt_definegroup(d,selectedcon);
else
    nbt_definegroup(d)
    h = gcf;
    waitfor(h) 
end

SelectedFiles = evalin('base','SelectedFiles');

%--- 3. select Biomarker
if (nargs<2 || isempty(P{2}))
    clear d
    d=SelectedFiles;
    eval(['evalin(''caller'',''clear SelectedFiles'');']);
    for i=1:length(d)
        if ~isempty(findstr('analysis',d(i).name))
            [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path,'/', d(i).name]);
            break
        end
    end
    [selection,ok]=listdlg('liststring',biomarker_objects, 'SelectionMode','single', 'ListSize',[250 200],'PromptString','Select biomarker object');
    biomarker_object=biomarker_objects{selection};
    if length(biomarkers{selection})>1
        [selection1,ok]=listdlg('liststring',biomarkers{selection},'SelectionMode','single', 'ListSize',[250 200],'PromptString','Select biomarker');
        biomarker=strcat(biomarker_object,'.',biomarkers{selection}(selection1));
    else
        biomarker=strcat(biomarker_object,'.',biomarkers{selection}(1));
    end
    biomarker=cell2mat(biomarker);
else biomarker = P{2};
    clear d
    d=SelectedFiles;
    eval(['evalin(''caller'',''clear SelectedFiles'');']);
    for i=1:length(d)
        if ~isempty(findstr('analysis',d(i).name))
            [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path,'/', d(i).name]);
            break
        end
    end
    findpoint = strfind(biomarker, '.');
    if isempty(findpoint)
        findbiom = find(strcmp(biomarker_objects(:),biomarker));
        if length(biomarkers{findbiom})>1
            [selection1,ok]=listdlg('liststring',biomarkers{findbiom},'SelectionMode','single', 'ListSize',[250 200],'PromptString','Select biomarker');
            biomarker=strcat(biomarker,'.',biomarkers{findbiom}(selection1));
            biomarker=cell2mat(biomarker);
        end
    end
end


SignalInfo=nbt_getInfoObject(path,'Signal'); % get one Info file for locations channels, in case of EEG data
%--- 4. get biomarkers from analysis files
for i = 1:length(d)
    [c1(:,i),s1{i},p1{i},unit]=nbt_load_analysis(path,d(i).name,biomarker,@nbt_get_biomarker,[],[],[]);
end
%--- 5. select statistical test
if nargs >= 4 && ~isempty(P{4})
    testnumber = P{4};
    statdata = nbt_selectstatistics(SignalInfo,c1,[],[],testnumber);
else
    statdata = nbt_selectstatistics(SignalInfo,c1);
    h = gcf;
    waitfor(h) 
    pause(0.1)
end
disp(['Computing statistics for ',regexprep(biomarker,'_',' '), '...'])

%--- 6. save
if nargs>=6 
    if ~isempty(P{5}) && ~isempty(P{6})
        savedir = P{6};
        groupname = P{5};
        nbt_save_statistics(2,d,statdata,biomarker,savedir,groupname);
    elseif ~isempty(P{5}) && isempty(P{6})
        savedir = [];
        groupname = P{5};
        nbt_save_statistics(2,d,statdata,biomarker,savedir,groupname);
    elseif isempty(P{5}) && ~isempty(P{6})
        savedir = P{6};
        nbt_save_statistics(2,d,statdata,biomarker,savedir)
    end
else
    nbt_save_statistics(2,d,statdata,biomarker); 
end

%--- 7. plots
% C = statdata.C;% confidence
% if size(C,1) == 6 % if subregions are selected
%     nbt_plot_stat(c1,statdata,biomarker)
% elseif size(C,1) == 129 && isfield(SignalInfo.Interface,'EEG') 
%     % if the signal has 129 channels and chanloc is specified in Interface.EEG
%     nbt_plot_stat_regions(SignalInfo,statdata,biomarker,unit)
%     nbt_plot_stat(c1,statdata,biomarker)
% else
%     nbt_plot_stat(c1,statdata,biomarker)
% end




