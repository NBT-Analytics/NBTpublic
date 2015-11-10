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


function [Data_filtered] = nbt_filter_firLp(Data,lp,fs,fir_order)
%
% Modified klaus.linkenkaer@cncr.vu.nl, 070521.
% Modified S. Poil, 12-Feb-2008, added warning for wrong filter order.
%
% 
%******************************************************************************************************************
% Purpose...
%
% Causal (feedforward) lowpass filter the signal 'F' with a Hamming window.
%
%
%******************************************************************************************************************
% Input parameters...
%
% Data          : data matrix (or vector), time along the 2nd dimension!
% lp            : lowpass corner (e.g., 13 Hz).
% fs            : sampling frequency.
% fir_order     : filter order in units of seconds (to prevent an influence of sampling frequency!)
%
%******************************************************************************************************************
% Default parameters (can be changed)...
% time window included in the filtering process.
% Filter orders suitable for alpha and beta oscillations and based on:
% Nikulin. 2005. Neurosci. Long-range temporal correlations in EEG
% oscillations...
%fir_order = 0.22;      % Use for high time resolution and low frequency resolution.
%fir_order = 0.38       % Use for low time resolution and high frequency
%resolution.
%**************************************************************************
% Warn if Data might have wrong dimensions
if(size(Data,2) > size(Data,1))
   % warning('Filter_fir:Dimension','Filter_fir::Input migth have wrong dimensions. Time should be along the 1st dimension! - Input has been transposed')
    Data = Data';
end
% Warn if filter order is too low
if(2/lp > fir_order)
    warning('Filter_fir:FilterOrder','Filter_fir:: The filter order is too low for the given high-pass frequency.')
    disp('Use minimum')
    disp(2/lp)
end

%******************************************************************************************************************
% Define filter characteristics:

b = fir1(floor(fir_order*fs),[lp]/(fs/2));
%freqz(b)
%[b,a] = butter(fir_order*fs/10,[hp lp]/(fs/2));

%******************************************************************************************************************
% Filter the vector 'F' using the filter characteristics from above:

Data_filtered = zeros(size(Data));
for ii = 1:size(Data,2)
 Data_filtered(:,ii) = filter(b,1,Data(:,ii));
end
end
