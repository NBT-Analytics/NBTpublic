% nbt_stat_conditions - Compute statistics between two conditions
%
% Usage:
%   [statdata]=nbt_stat_conditions
%   or
%   [statdata]=nbt_stat_conditions(path,cond1,cond2,biomarker)
%
% Inputs:
%   path
%   cond1 string
%   cond2 string
%   biomarker string biomarker name
%
% Outputs:
%   plot   
%
% Example:
%   nbt_stat_conditions('/Users/Giusi/Documents/NBT/database/ConvertedFiles
%   ','ECR1', 'EOR1','amplitude_13_30_Hz')
%   
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by Rick Jansen(2012), see NBT website
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


function[statdata]=nbt_stat_conditions(varargin)
%--- assign fields
P=varargin;
nargs=length(P);
coolWarm = load('nbt_CoolWarm.mat','coolWarm');
% --- 1.select folder
if (nargs<1 || isempty(P{1})) 
    disp('select folder with NBT files');
    [path]=uigetdir(); 
else
    path = P{1}; 
end;
d=dir(path);
SelectedFiles = 0;
assignin('base','SelectedFiles',SelectedFiles);
% --- 2.select conditions
if nargin<2 || isempty(P{2})
    nbt_defineconditions(d);
    h = gcf;
    waitfor(h) 
    SelectedFiles = evalin('base','SelectedFiles');
else
    nbt_defineconditions(d,P{2},P{3});
    SelectedFiles = evalin('base','SelectedFiles');
end
d1 = SelectedFiles.d1;
d2 = SelectedFiles.d2;
eval(['evalin(''caller'',''clear SelectedFiles'');']);
clear d
d = [d1 d2];
%--- 3. select Biomarker
if (nargs<4 || isempty(P{4}))
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
else biomarker = P{4};
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
dots = strfind(d1(1).name,'.');
undersc = strfind(d1(1).name,'_');
cond1 = d1(1).name(dots(end-1)+1:undersc-1);
dots = strfind(d2(1).name,'.');
undersc = strfind(d2(1).name,'_');
cond2 = d2(1).name(dots(end-1)+1:undersc-1);
SignalInfo=nbt_getInfoObject(path,'Signal'); % get one Info file for locations channels, in case of EEG data
%--- 4. get biomarkers from analysis files
[c1,s1,p1,unit]=nbt_load_analysis(path,cond1,biomarker,@nbt_get_biomarker,[],[],[]);
[c2,s2,p2]=nbt_load_analysis(path,cond2,biomarker,@nbt_get_biomarker,[],[],[]);
%--- 5. check if c1 & c2 contain the same subjects
if size(c1,2)~=size(c2,2)
    error('ERROR: Not all subjects are present for both conditions, please add files');
    return;
else
    for i=1:length(s1)
        if ~strcmp(s1{i},s2{i})
            %     if size(find((s1 == s2) == 0),1) > 0
            error('ERROR: The same subjects are not being compared. Check that you only have analysis files for the same subjects in the directory');
            return;
        end
    end
end
%--- 6. select statistical test
diffC2C1= c2 - c1;
statdata = nbt_selectstatistics(SignalInfo, c1,c2,1);
disp(['Computing statistics for ',regexprep(biomarker,'_',' ')])
disp(['for condition ',cond1,' and condition ',cond2])
h = gcf;
waitfor(h) 
pause(0.1)
%--- 7. save
nbt_save_statistics(3,d,statdata,biomarker,[],strcat(cond1,'_vs_',cond2));
%---plot
C = statdata.C;% confidence
if size(C,1) == 6
   nbt_plot_stat(diffC2C1,statdata,biomarker, cond1, cond2);
elseif size(C,1) == 129 && isfield(SignalInfo.Interface,'EEG') % if the signal has 129 channels and chanloc is specified in Interface.EEG
    nbt_plot_stat_regions(SignalInfo,statdata,biomarker,unit,cond1,cond2)
    nbt_plot_stat(diffC2C1,statdata,biomarker, cond1, cond2);
else
    nbt_plot_stat(diffC2C1,statdata,biomarker, cond1, cond2);
end
