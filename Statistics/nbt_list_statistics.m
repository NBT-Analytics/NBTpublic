% nbt_list_statistics
%
% Usage:
%   nbt_save_statistics
%   or
%   nbt_save_statistics(path)
%
% Inputs:
%   path  where the statistic file is stored
%
% Outputs:
%
% Example:
%
%   
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by giuseppina Schiavone (2012), see NBT website
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
function nbt_list_statistics(varargin)
%--- assign fields
P=varargin;
nargs=length(P);
%--- 1. select Folder
if (nargs<1 || isempty(P{1})) 
    disp('Select folder with first group of NBT files to analyze');
    [path]=uigetdir([],'Select folder with first group of NBT files to analyze'); 
else
    path = P{1};
end;
%--- 2 ID project
Sub = cell(1);
Con  = cell(1);
Gr = cell(1);
Grs = cell(1);
idproject = '';
if (nargs<2 || isempty(P{2})) 
    d  = dir(path);
    for i = 1:length(d)
        if ~isempty(findstr(d(i).name,'_statistics.mat')) && isempty(findstr(d(i).name(1),'.'))
            underscpos = findstr(d(i).name,'_');
            idproject = d(i).name(1:underscpos(1)-1);
            break
        end
    end
    if isempty(idproject)
        disp('NBT Statistics file not found!')
        return
    end
else
    idproject = P{2};
end;
if isfield(load([path '/' idproject '_statistics.mat']),'subject')
    load([path '/' idproject '_statistics.mat'],'subject')
    for i = 1:length(subject)
        Sub{i} = [subject(i).IDproject '_' subject(i).IDsubject];
    end
    eval(['evalin(''caller'',''clear subject'');']);
end
if isfield(load([path '/' idproject '_statistics.mat']),'group')
    load([path '/' idproject '_statistics.mat'],'group')
    for i = 1:length(group)
        Gr{i} = [group(i).IDproject '_' group(i).groupname];
    end
    eval(['evalin(''caller'',''clear group'');']);
end
if isfield(load([path '/' idproject '_statistics.mat']),'conditions')
    load([path '/' idproject '_statistics.mat'],'conditions')
    for i = 1:length(conditions)
        Con{i} = [conditions(i).IDproject '_' conditions(i).conditionsname];
    end
    eval(['evalin(''caller'',''clear conditions'');']);
end
if isfield(load([path '/' idproject '_statistics.mat']),'groups')
    load([path '/' idproject '_statistics.mat'],'groups')
    for i = 1:length(groups)
        Grs{i} = [groups(i).IDproject '_' groups(i).groupsname];
    end
    eval(['evalin(''caller'',''clear groups'');']);
end

ListStat{1} = 'SUBJECT';
ListStat{length(ListStat)+1} = ' ';
for i = 1:length(Sub)
    ListStat{length(ListStat)+1} = Sub{i};
end
ListStat{length(ListStat)+1} = ' ';
ListStat{length(ListStat)+1} = 'GROUP';
ListStat{length(ListStat)+1} = ' ';
for i = 1:length(Gr)
    ListStat{length(ListStat)+1} = Gr{i};
end
ListStat{length(ListStat)+1} = ' ';
ListStat{length(ListStat)+1} = 'CONDITIONS';
ListStat{length(ListStat)+1} = ' ';
for i = 1:length(Con)
    ListStat{length(ListStat)+1} = Con{i};
end
ListStat{length(ListStat)+1} = ' ';
ListStat{length(ListStat)+1} = 'GROUPS';
ListStat{length(ListStat)+1} = ' ';
for i = 1:length(Grs)
    ListStat{length(ListStat)+1} = Grs{i};
end
msgbox(ListStat,'Statistics', 'normal')
