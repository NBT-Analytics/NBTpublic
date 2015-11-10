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

function [B_values_cell,Sub,Proj,unit] = nbt_checkif_groupdiff(Group,G,n_files,bioms_name,Bpath)

if  ~isempty(Group.group_difference)% check if the group comes from a group difference
    diffname = Group.group_difference;
    findminus = findstr(diffname,'-');
    g_diff1 = strtrim(diffname(1:findminus-1));
    g_diff2 = strtrim(diffname(findminus+1:end));
    for i = 1:length(G)
        if strcmp(strtrim(G(i).fileslist(1).group_name),g_diff1)
            firstG = i;
            break
        end
    end
    for i = 1:length(G)
        if strcmp(strtrim(G(i).fileslist(1).group_name),g_diff2)
            secondG = i;
            break
        end
    end
    firstG = G(firstG);
    secondG = G(secondG);
    Bpath1=firstG.fileslist(1, 1).path;
    Bpath2=secondG.fileslist(1, 1).path;
    if n_files ~= length(firstG.fileslist)
        n_files =length(firstG.fileslist);
    end
    for j = 1:n_files % subjects
        disp(j)
        for l = 1:length(bioms_name) % biomarker
            namefilefirstG = firstG.fileslist(j).name;
            [B_values_cellfirstG{j,l},Sub,Proj,unit{j,l}]=nbt_load_analysis(Bpath1,namefilefirstG,bioms_name{l},@nbt_get_biomarker,[],[],[]);
            namefilesecondG = secondG.fileslist(j).name;
            [B_values_cellsecondG{j,l},Sub,Proj,unit{j,l}]=nbt_load_analysis(Bpath2,namefilesecondG,bioms_name{l},@nbt_get_biomarker,[],[],[]);
            B_values_cell{j,l} = B_values_cellfirstG{j,l}-B_values_cellsecondG{j,l};
        end
    end
else
    for j = 1:n_files % subjects
        disp(j)
        for l = 1:length(bioms_name) % biomarker
            namefile = Group.fileslist(j).name;
            Bpath = Group.fileslist(j).path;
            [B_values_cell{j,l},Sub,Proj,unit{j,l}]=nbt_load_analysis(Bpath,namefile,bioms_name{l},@nbt_get_biomarker,[],[],[]);
        end
    end
end
