% ConvertEGIrawToNBT(varargin) - Converts one EGI .raw file to NBTSignal object and adds EEG fields to Info object -
%
% Usage:
%  [Signal,Info] = Convert_one_EGIraw_file_ToNBT(dir,Info,filename)
%
% Inputs:
%  dir = directory at which the .raw file is located.
%  Info = Info object
%  filename =  filename from .raw file you want to convert

% Outputs:
%   Signal = NBTsignal object
%   Info = modified Info object

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
function[Signal,Info] = Convert_one_EGIraw_file_ToNBT(dir,Info,filename)

% disp([dir,filename])
EEG = pop_readegi([dir,filename,'.raw']);

EEG.chanlocs = readlocs('GSN-HydroCel-129.sfp');
EEG = eeg_checkset(EEG);

Signal=EEG.data;
EEG=rmfield(EEG,'data');
EEG.setname = Info.file_name;
Info.Interface.EEG = EEG;
Info.original_sample_frequency = EEG.srate;

Signal =  NBTSignal(Signal,EEG.srate,[],0,129,[], [], [],[], [], [], [],[]); % create data object

end