% nbt_selectbiomarkers - this function is part of the statistics GUI, it allows
% to select biomarkers for your statistics
%
% Usage:
%  G = nbt_selectbiomarkers(G)
%
% Inputs:
%   G is the struct variable containing informations on the selected groups
%      i.e.:  G(1).fileslist contains information on the files of Group 1
% Outputs:
%  G updated version of the input, enriched with the field biomarkerlist
%    i.e.:  G(1).fileslist contains information on the files of Group 1
%           G(1).biomarkerslist list of selected biomarkers for the
%           statistics
%
% Example:
%    G = nbt_selectbiomarkers(G)
%
% References:
%
% See also:
%  nbt_ExtractBiomarkers

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


function nbt_selectbiomarkers
G=evalin('base', 'G');

path = G(1).fileslist.path;
name = G(1).fileslist(1).name;
% --- extract biomarkers
[biomarker_objects,biomarkers] = nbt_ExtractBiomarkers([path filesep name]);


k = 1;
for i = 1:length(biomarker_objects)
    tmp = biomarkers{i};
    for j = 1:length(tmp)
        biom{k} = [biomarker_objects{i} '.' tmp{j}];
        k = k+1;
    end
end
% --- display biomarkers list interface
%[selection,ok]=listdlg('liststring',biom,'SelectionMode','multiple','ListSize',[250 300],'PromptString','Select biomarker object');
biomarkerslist = biom(:);
for i = 1:length(G)
    G(i).biomarkerslist = biomarkerslist;
end
%disp('Biomarkers Selection Completed.')
assignin('base', 'G',G);
end
