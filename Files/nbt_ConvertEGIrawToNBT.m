% ConvertEGIrawToNBT(varargin) - Converts EGI .raw files to NBTSignal object -
%
% Usage:
%   >>  ConvertEGIrawToNBT
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
function ConvertEGIrawToNBT(varargin)
% specify folder containing files
if (length(varargin)<1 ||isempty(varargin{1}) || ~ischar(varargin{1}))
    data_directoryname = uigetdir('C:\','Please select a folder with EGI signal files you want to convert');
else
    data_directoryname=varargin{1};
end
if length(varargin)<2 || isempty(varargin{2})
    save_directoryname = uigetdir('C:\','Please select a folder in which you want to save the NBT files');
else
    save_directoryname=varargin{2};
end

current=cd;
cd ([data_directoryname]);
d = dir(data_directoryname);


% looping through all files in folder
for j=3:length(d)
    if (~d(j).isdir)
        FileEx = strfind(d(j).name,'raw');
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
            filename = [d(j).name];
            disp('File loading... Please Wait')
            
            EEG = pop_readegi([filename]);
            
            
            EEG.chanlocs = readlocs('GSN-HydroCel-129.sfp');
            EEG.setname = d(j).name(1:(FileNameIndex(4)-1));
            EEG = eeg_checkset(EEG);
            
            %% make Info object
            RawSignalInfo = Info_Object(EEG.setname,[],[],DateRec,EEG.srate,EEG.srate,[],[],[],[],[],[],[]);
            
            
            Signal=EEG.data';
            EEG=rmfield(EEG,'data');
            RawSignalInfo.Interface.EEG = EEG;
            RawSignalInfo.projectID = ProjectID;
            RawSignalInfo.subjectID = SubjectID;
            RawSignalInfo.condition = Condition;
            
            RawSignal =  NBTSignal(Signal,RawSignalInfo.converted_sample_frequency,SubjectID,0,129,DateRec, Condition, [],[], [], ProjectID, [],[]); % create signal object with data
            
            
            disp('Writing to disk... Please Wait')
            
            save ([save_directoryname,'/',filename(1:end-4),'.mat'], 'RawSignal','RawSignalInfo')
            disp('File saved')
        else
            disp('No .raw files found in folder')
        end
    end
end
cd(current)
end