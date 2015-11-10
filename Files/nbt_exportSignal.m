% ExSignal = nbt_exportSignal(Signal, SignalInfo)
% 
% Export NBT Signal to a matrix
%
% Usage:
%   ExSignal = nbt_exportSignal(Signal, SignalInfo);
%
% Inputs:
%   Signal     
%   SignalInfo     
%    
% Outputs:
%   ExSignal     - matrix
%
% Example:
%   ExSignal = nbt_exportSignal(Signal, SignalInfo)
%
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by "" (year), see NBT website for current email address
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
% ---------------------------------------------------------------------------------------


function ExSignal = nbt_exportSignal(Signal, SignalInfo)


if isfield(SignalInfo.Interface,'noisey_intervals')
    intervals=SignalInfo.Interface.noisey_intervals;
    good=1:size(Signal,1);
    for i=1:size(intervals,1)
        good = setdiff(good, intervals(i,1):intervals(i,2));
    end
    ExSignal = Signal(good,:);
end

%--- Set bad channels to NaN
ExSignal(:,SignalInfo.BadChannels) = nan;
disp('Signal exported as a matrix in ExSignal')

