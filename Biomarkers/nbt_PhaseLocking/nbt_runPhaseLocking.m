% nbt_runPhaseLocking - Run computation of phase locking among channels for the frequency 
% range [8 13], and save the biomarker in the analysis.mat file; 
%
% Usage:
%   nbt_runPhaseLocking(Signal, SignalInfo, SaveDir)
%
% Inputs:
%   Signal
%   SignalInfo
%   SaveDir - directory where you want to save the analysis file
%
% Outputs: 
%
% Example:
%    It is possible to add more biomarkers for computation in this file:
%    i.e. adding the following lines:
%    PhaseLocking8_13Hz = nbt_doPhaseLocking(Signal,SignalInfo,[20 40]);
%    save biomarker
%    nbt_SaveClearObject('PhaseLocking8_13Hz',SignalInfo,SaveDir);
%    it will also compute and save the phase locking biomarker for the
%    frequency range [20 40] Hz
%
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by Giuseppina Schiavone (2011), see NBT website (http://www.nbtwiki.net) for current email address
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
function nbt_runPhaseLocking(Signal, SignalInfo, SaveDir)
% compute biomarker
PhaseLocking8_13Hz = nbt_doPhaseLocking(Signal,SignalInfo,[8 13],[10 30]);
% save biomarker
nbt_SaveClearObject('PhaseLocking8_13Hz',SignalInfo,SaveDir);
end