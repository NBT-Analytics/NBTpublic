% ConvertEGImatToNBT(varargin) - Converts EGI .mat files to NBTSignal object -
%
% Usage:
%   >>  ConvertEGImatToNBT
%
% Inputs:
%    None
% Outputs:
%   Will convert all files in the directory you give
%
% See also:

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
function nbt_ConvertEGImatToNBT(varargin)
% specify folder containing files
directoryname = uigetdir('C:\','Please select a folder with EGI signal files');
disp('Reading folder...')
d = dir(directoryname);
cd ([directoryname]);

% ask reseacher to enter information
answer = 'n';
while answer ~= 'y'
    Fs = input('Sampling frequency = ');
    ReseacherID = input('Reseacher ID : ' ,'s');
    answer = input('Information correct [y/n]? ','s');
end

% looping through all files in folder
for j=3:length(d)
    if (~d(j).isdir)
        FileEx = strfind(d(j).name,'mat');
        if( ~isempty(FileEx))
            % Find information from filename
            FileNameIndex = strfind(d(j).name,'.');
            ProjectID = d(j).name(1:(FileNameIndex(1)-1));
            SubjectID = d(j).name((FileNameIndex(1)+2):(FileNameIndex(2)-1));
            DateRec   = d(j).name((FileNameIndex(2)+1):(FileNameIndex(3)-1));
            Condition = d(j).name((FileNameIndex(3)+1):(FileNameIndex(4)-1));
            
            % and load file
            disp('Filename:')
            disp(d(j).name)
            disp('File loading... Please Wait')
            load ([d(j).name])
            
            
            % Find signal in file using the size of the signal array
            VariableList = whos;
            Signalname = [];
            
            for i = 1:length(VariableList(:))
                if(VariableList(i).size(1) == 129 && VariableList(i).size(2) > 1)
                    Signalname = VariableList(i).name;
                    break
                end
            end
            if (isempty(Signalname)) % i.e. no signal in file
                disp('No Signal in File, or File already in NBTsignal format')
                continue
            end
            
            
            
            
            
            % create NBT Signal and save.
            Signal = eval(Signalname);
            Signal = Signal';
            clear ([Signalname])
            
            EEG=eeg_emptyset;
            
            EEG.nbchan = min(size(Signal));
            EEG.ref = 129;
            EEG.srate = Fs;
            EEG.trials = 1;
            EEG.data = Signal';
            EEG = eeg_checkset(EEG);
            [EEG] = pop_resample( EEG, 200);
            Signal = EEG.data';
            EEG.data = [];
            EEG.chanlocs = readlocs('GSN-HydroCel-129.sfp');
            EEG = eeg_checkset(EEG);
            
            SignalInfo = nbt_CreateInfoObject(d(j).name, 'mat', Fs);
            SignalInfo.Interface.EEG = EEG;
            
            disp('Writing to disk... Please Wait')
            save ([d(j).name], 'Signal')
            save ([d(j).name(1:end-4) '_info.mat'], 'SignalInfo')
            disp('File saved')
        end
    end
end
end