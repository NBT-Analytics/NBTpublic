% nbt_runCrossPhaseLocking - Run computation of cross phase locking among channels for the frequency 
% range [8 13] and [20 50], and save the biomarker in the analysis.mat file; 
%
% Usage:
%   nbt_runCrossPhaseLocking(Signal, SignalInfo, SaveDir)
%
% Inputs:
%   Signal
%   SignalInfo
%   SaveDir - directory where you want to save the analysis file
%
% Outputs: 
%
% Example:
%    It is possible to add more biomarkers for computation in this file.
%
% References:
% 
% See also: 
%  
  
%------------------------------------------------------------------------------------
% Originally created by "your name" (2010), see NBT website (http://www.nbtwiki.net) for current email address
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
function nbt_runCrossPhaseLocking(Signal, SignalInfo, SaveDir)
% compute biomarker
CrossPhaseLocking8_13Hz20_50Hz = nbt_doCrossPhaseLocking(Signal,SignalInfo,[8 13; 20 50]);
% save biomarker
nbt_SaveClearObject('CrossPhaseLocking8_13Hz20_50Hz',SignalInfo,SaveDir);
end