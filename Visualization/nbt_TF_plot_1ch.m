% Copyright (C) 2008  Neuronal Oscillations and Cognition group, Department of Integrative Neurophysiology, Center for Neurogenomics and Cognitive Research, Neuroscience Campus Amsterdam, VU University Amsterdam.
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
%

% ChangeLog - see version control log for details
% <date> - Version <#> - <text>

function [W,t,frq] = nbt_TF_plot_1ch(Data,Fs,Frq_low,Frq_high,Frq_step,Plot_TFR);
%[W,t,frq] = TF_plot_1ch(NBTSignal,Frq_low,Frq_high,Frq_step,Plot_TFR);
%**************************************************************************
% Purpose:
%
% Compute the wavelet transform in the frequency range from 'Frq_low' to
% 'Frq_high' in steps of 'Frq_step'.
% If 'Frq_low' is set equal to 'Frq_high', the result is a wavelet
% filtering a at single frequency.
%
%**************************************************************************
% Example...
%
%
%**************************************************************************
% Input...
%
% Data     	: data vector.
% Fs	  	: sampling frequency of the INPUT data matrix M.
% Frq_low 	: lowest frequency in the time-frequency (TF) matrix.
% Frq_high 	: highest frequency in the time-frequency matrix.
% Frq_step 	: spacing of frequency lines in TF matrix or TF plot.
%
%
%**************************************************************************
% Output...
%
% W         : the matrix containing the wavelet transform (complex!).
% t         : vector with time points in units of seconds (for plotting).
% frq       : vector with frequencies in units of Hz (for plotting).
%
%***************************************************************************
% TF wavelet analysis...

[W,p,s,coi] = nbt_wavelet33(Data,1/Fs,1,Frq_step,1.033*Frq_low,1.033*Frq_high);

t = 1/Fs:1/Fs:length(Data)/Fs;
frq = Frq_low:Frq_step:Frq_high;
%frq = fliplr(1./p);
if Plot_TFR == 1
  figure
    imagesc(t,frq,flipud(sqrt(abs(W)))); axis xy
 %  imagesc(t,f,(abs(W))); axis xy
    colorbar
end
