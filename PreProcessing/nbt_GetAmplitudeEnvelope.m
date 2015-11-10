% nbt_GetAmplitudeEnvelope() - Returns the amplitude envelope (absolute hilbert
% transform of band-pass filtered signal. The signal is band-pass filtered
% using a FIR1 filter
%
% Usage:
%   >>  [SignalAmplitudeEnvelope, SignalInfo] = GetAmplitudeEnvelope(Signal, SignalInfo, hp, lp, filter_order)
%
% Inputs:
%   NBTSignalObject     - NBTSignal Object
%   hp     - high-pass edge (Hz), i.e. 8 Hz for alpha frequency
%   lp     - low-pass edge (Hz), i.e. 13 Hz for alpha freqeuncy
%   filter_order - the filter_order of the FIR1 filter in seconds. Should
%   be at least 2 times longer than the shortes oscillation cycle in the
%   band
%    
% Outputs:
%   SignalAmplitudeEnvelope    - An NBTsignal object with the amplitude
%   envelope
%
% Example:
%
% References:
% 
%
% See also: 
%  FILTER_FIR  

  
%------------------------------------------------------------------------------------
% Originally created by "Simon-Shlomo Poil" 2009, see NBT website (http://www.nbtwiki.net) for current email address
%------------------------------------------------------------------------------------
%
% ChangeLog - see version control log at NBT website for details.
%
% Copyright (C) 2009 Simon-Shlomo Poil  (Neuronal Oscillations and Cognition group, 
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
% 

function [Signal, SignalInfo] = nbt_GetAmplitudeEnvelope(Signal, SignalInfo, hp, lp, filter_order)
 Signal = abs(hilbert(nbt_filter_fir(Signal(:,:),hp,lp,SignalInfo.converted_sample_frequency,filter_order)));
 SignalInfo.frequencyRange = [hp lp];
end