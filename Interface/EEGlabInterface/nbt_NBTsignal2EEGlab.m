% EEG = nbt_NBTsignal2EEGlab 
% Will load NBTsignal and return it info EEGLAB format
%
% Usage:
%  EEG=NBTsignal2EEGlab creates EEGlab structure EEG, 
% or 
%  EEG=NBTsignal2EEGlab(path_filename)
% or 
%  EEG=NBTsignal2EEGlab(path_filename,save) if save == 1 save the EEG file
% or
% EEG=nbt_NBTtoEEG(Signal, SignalInfo, SignalPath) in case your signal is
% already in the workspace
%
% Outputs:
%   EEG : EEGLAB EEG structure.
%
% Warning: if the file you are trying to convert is not in NBT Data Format, it
% will be converted in NBT Data Format and Signal and Info files will be
% saved in the source directory of your file
%
% See also:
%   nbt_EEGlab2NBTsignal

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


function [EEG SignalPath] = nbt_NBTsignal2EEGlab(varargin)
P=varargin;
nargs=length(P);

if nargs == 3
    Signal= P{1};
    SignalInfo = P{2}; 
    SignalPath = P{3};
    if(isempty(SignalInfo.Interface.EEG))    
    EEG = eeg_emptyset;
    else
        EEG = SignalInfo.Interface.EEG;
    end
    EEG.data = Signal(:,:)';
    EEG.srate = SignalInfo.converted_sample_frequency;
    EEG.setname = SignalInfo.file_name;

    EEG.pnts = size(EEG.data,2);
    SignalInfo.Interface.EEG=[];
    EEG.NBTinfo = SignalInfo;

    %Remove noisy intervals
    if(isfield(SignalInfo.Interface,'noisey_intervals'))
    EEG = eeg_eegrej(EEG,SignalInfo.Interface.noisey_intervals);
    SignalInfo.Interface.noisey_intervals = [];
    eval(['save(' ' ''' SignalPath SignalInfo.file_name '_info.mat'' , ''SignalInfo'')' ])
    end

    EEG.NBTinfo = SignalInfo;
    EEG = eeg_checkset(EEG);

else

%--- load NBT file
disp('File information loading...')
if isempty(varargin)
    [Signal,SignalInfo,SignalPath]=nbt_load_file();
else
    path_filename=varargin{1};
    [Signal,SignalInfo,SignalPath]=nbt_load_file(path_filename);
end

%--- Set EEGlab fields
try
    EEG = SignalInfo.Interface.EEG;
catch
    EEG = eeg_emptyset;
end

EEG.setname  = SignalInfo.file_name;

if isempty(SignalInfo.converted_sample_frequency);
    EEG.srate = SignalInfo.original_sample_frequency;
else
    EEG.srate = SignalInfo.converted_sample_frequency;
end

EEG.data = Signal';

EEG.pnts = size(EEG.data,2);
SignalInfo.Interface.EEG=[];
EEG.NBTinfo = SignalInfo;
EEG = eeg_checkset(EEG);

%--- save EEGlab structure if wanted

if length(varargin)==2
    if varargin{2}==1
        directoryname = uigetdir;
        d = dir(directoryname);
        save([directoryname,'/',EEG.setname,'.mat'],'EEG')
    end
end
end