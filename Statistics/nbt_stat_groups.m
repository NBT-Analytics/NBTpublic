% nbt_stat_groups - Compute statistics between groups
%
% Usage:
%   [statdata]=nbt_stat_groups
%   or
%   [statdata]=nbt_stat_groups(path1,path2,biomarkername)
%   or
%   [statdata]=nbt_stat_groups(path1,path2,biomarkername,groupsname)
%
% Inputs:
%   path
%
% Outputs:
%   plot   
%
% Example:
%   nbt_stat_groups('/Users/Giusi/Documents/NBT/database/ConvertedFiles','/Users/Giusi/Documents/NBT/database/ConvertedFiles','amplitude_13_30_Hz')
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

function[statdata]=nbt_stat_groups(varargin)
%--- assign fields
P=varargin;
nargs=length(P);
%--- 1. select Folders
if (nargs<1 || isempty(P{1})) 
    disp('Select folder with first group of NBT files to analyze');
    [path1]=uigetdir([],'Select folder with first group of NBT files to analyze'); 
else
    path1 = P{1};
end;
if (nargs<2 || isempty(P{2})) 
    disp('Select folder with second group of NBT files to analyze');
    [path2]=uigetdir([],'Select folder with second group of NBT files to analyze'); 
else
    path2 = P{2};
end;
%--- 2. define the group 1
disp('Define the first Group ...');
d1=dir(path1);
SelectedFiles = 0;
assignin('base','SelectedFiles',SelectedFiles);
nbt_definegroup(d1)
h = gcf;
waitfor(h) 
SelectedFiles = evalin('base','SelectedFiles');
clear d1
d1 = SelectedFiles;
eval(['evalin(''caller'',''clear SelectedFiles'');']);

%--- 3. define the group 2
disp('Define the second Group ...');
d2=dir(path2);
SelectedFiles = 0;
assignin('base','SelectedFiles',SelectedFiles);
nbt_definegroup(d2)
h = gcf;
waitfor(h) 
SelectedFiles = evalin('base','SelectedFiles');
clear d2
d2 = SelectedFiles;
eval(['evalin(''caller'',''clear SelectedFiles'');']);
%---4. get biomarker
d = d1;
if (nargs<3 || isempty(P{3}))
    for i=1:length(d)
        if ~isempty(findstr('analysis',d(i).name))
            [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path1,'/', d(i).name]);
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
else biomarker = P{3};
    for i=1:length(d)
        if ~isempty(findstr('analysis',d(i).name))
            [biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path1,'/', d(i).name]);
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
SignalInfo=nbt_getInfoObject(path1,'Signal'); % get one Info file for locations channels, in case of EEG data
for i = 1:length(d1)
    [c1(:,i),s1{i},p1{i},unit]=nbt_load_analysis(path1,d1(i).name,biomarker,@nbt_get_biomarker,[],[],[]);
end
for i = 1:length(d2)
    [c2(:,i),s2{i},p2{i}]=nbt_load_analysis(path2,d2(i).name,biomarker,@nbt_get_biomarker,[],[],[]);
end
%--- 5. check if c1 & c2 contain the same subjects
% % if size(c1,2)~=size(c2,2)
% %     error('ERROR: Not all subjects are present for same biomarker, please add files');
% %     return;
% % else
% %     for i=1:length(s1)
% %         if ~strcmp(s1{i},s2{i})
% %             %     if size(find((s1 == s2) == 0),1) > 0
% %             error('ERROR: The same subjects are not being compared. Check that you only have analysis files for the same subjects in the directory');
% %             return;
% %         end
% %     end
% % end
%--- 6. select statistical test
statdata = nbt_selectstatistics(SignalInfo,c1,c2);
disp(['Computing statistics for ',regexprep(biomarker,'_',' '), '...'])
h = gcf;
waitfor(h) 
pause(0.1)
d = [d1 d2];
%--- 7.save 
if (nargs<4 || isempty(P{4}))
    nbt_save_statistics(4,d,statdata,biomarker);
else
    groupsname = P{4};
    nbt_save_statistics(4,d,statdata,biomarker,[],groupsname);
end
%--- 8.plot
p_biomarkers = statdata.p;% p-value
if size(p_biomarkers,2) == 6
    nbt_plot_stat_groups(c1,c2,statdata,biomarker)
elseif size(p_biomarkers,2) == 129 && isfield(SignalInfo.Interface,'EEG') % if the signal has 129 channels and chanloc is specified in Interface.EEG
    nbt_plot_stat_regions(SignalInfo,statdata,biomarker,unit)
    nbt_plot_stat_groups(c1,c2,statdata,biomarker)
else
    nbt_plot_stat_groups(c1,c2,statdata,biomarker)
       nbt_plot_stat_regions(SignalInfo,statdata,biomarker,unit)
end


