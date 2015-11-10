% nbt_export_biomarker - Export biomarkers to external formal
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


function[statdata]=nbt_export_biomarker(varargin)
%--- assign fields
P=varargin;
nargs=length(P);
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
    nbt_defineconditions(d,[],[],1);
    h = gcf;
    waitfor(h) 
    SelectedFiles = evalin('base','SelectedFiles');
else
    nbt_defineconditions(d,P{2},P{3});
    SelectedFiles = evalin('base','SelectedFiles');
end
d = SelectedFiles.d1;

eval(['evalin(''caller'',''clear SelectedFiles'');']);


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
dots = strfind(d(1).name,'.');
undersc = strfind(d(1).name,'_');
cond1 = d(1).name(dots(end-1)+1:undersc-1);

SignalInfo=nbt_getInfoObject(path,'Signal'); % get one Info file for locations channels, in case of EEG data
%--- 4. get biomarkers from analysis files
[c1,s1,p1,unit]=nbt_load_analysis(path,cond1,biomarker,@nbt_get_biomarker,[],[],[]);
for i=1:16
    for m=1:5
        mm = c1{m,i};
        data(i,m) = sqrt(sum(mm([1 11 42 3 32 44 24 46 20 13 48 5 36 28 50 26 52 22 15 54 7 38 9 56 34]).^2)/25);
        data2(i,m) = sqrt(sum(mm([2 4 43 12 21 47 25 45 33 37 6 49 14 23 53 27 51 29 8 55 16 39 10 57 35]).^2)/25);
    end
    end
disp('break')
end
