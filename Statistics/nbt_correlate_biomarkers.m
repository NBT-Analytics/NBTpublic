% nbt_correlate_biomarkers - this function is part of the statistics GUI, it allows
% to calculate  correlations between biomarkers and subsequent
% analysis(PCA, cluster)

% Usage:
%  G = nbt_correlate_biomarkers (G);
%
% Inputs:
%   G is the struct variable containing informations on the selected groups
%      i.e.:  G(1).fileslist contains information on the files of Group 1
%           G(1).biomarkerslist list of selected biomarkers for the
%           statistics
%           G(1).chansregs list of the channels and the regions relected
% Outputs:
%  G updated version of the input,
%
%
% Example:
%   G = nbt_selectrunstatistics(G);
%
% References:
%
% See also:
%  nbt_load_analysis,
%  nbt_run_stat_group, nbt_run_stat_2groups_or_2conditions,
%  nbt_plot_2conditions_topo, nbt_statisticslog

%------------------------------------------------------------------------------------
% Originally created by RIck Jansen(2012), see NBT website (http://www.nbtwiki.net) for current email address
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

function G = nbt_correlate_biomarkers(G)

% select Group
for i = 1:length(G)
    gname = G(i).fileslist(1).group_name;
    groupList{i} = ['Group ' num2str(i) ' : ' gname]
end

end

