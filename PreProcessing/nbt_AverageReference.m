% AverageReference() - Average reference data excluding bad channels
%
% Usage:
%   EEG=AverageReference(EEG)
%
% Inputs:
%   EEG     - EEGlab structure
%    
% Outputs:
%   EEG     - EEGlab structure
%

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

function EEG=nbt_AverageReference(EEG)
    if size(EEG.chanlocs,2) ~= EEG.nbchan
        error('Number of channels does not match channel locations; use nbt_Missing_BadChannels to correct this')
       %badCh = nbt_Missing_BadChannels(EEG);
       %EEG = pop_reref(EEG,[],'exclude',find(badCh));
    else
            EEG = pop_reref(EEG,[],'exclude',find(EEG.NBTinfo.BadChannels));
    end
end