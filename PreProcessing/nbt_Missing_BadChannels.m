% BadChannels = nbt_Missing_BadChannels(EEG)
%Rewrites channel labels.  For those channels that are missing they are
%labelled as NaN.
%Assumes Cz channel has not been removed, and that order is always kept the
%same
% Usage:
%   BadChannels = nbt_Missing_BadChannels(EEG)
%
% Inputs:
%   EEG     - EEGlab structure

%--------------------------------------------------------------------------
% Copyright (C) 2008  Neuronal Oscillations and Cognition group, 
% Department of Integrative Neurophysiology, Center for Neurogenomics and 
% Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%--------------------------------------------------------------------------

function BadChannels = nbt_Missing_BadChannels(EEG)
offset = 0;
BadChannels = zeros(EEG.nbchan,1);
clear newInfo.Interface.EEG.chanlocs
for i = 1:EEG.nbchan-1
    
    if i == str2num(EEG.chanlocs(i+offset).labels(:,2:end))
        %newInfo.Interface.EEG.chanlocs(i) = Info.Interface.EEG.chanlocs(i+offset);
    else
%        newInfo.Interface.EEG.chanlocs(i + offset).labels = sprintf('E%i',i+offset);
        EEG.chanlocs(i).labels = 'NaN';
        BadChannels(i) = 1;
        offset = offset - 1;
    end
end
%newInfo.Interface.EEG.chanlocs(129) = Info.Interface.EEG.chanlocs(end);
end
