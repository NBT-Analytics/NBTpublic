% ReadEGIraw(varargin) 
%   Reads an EGI .raw file and saves it as an NBTSignal object -
%
% Usage:
%   EEG=nbt_ReadEGIraw(readSegmentFlag)
%   or
%   EEG=nbt_ReadEGIraw
%
% Inputs:
%    None
%
% Outputs:
%   Will save the NBTSignal in a .mat file, and read in the Signal in
%   EEGlab
%
% Example:
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

%
function EEG=nbt_ReadEGIraw(ReadSegmentFlag)
% specify filename, ask user
[filename, filepath] = uigetfile('*.RAW;*.raw', ...
    'Choose an EGI RAW file -- nbt_ReadEGIraw');

fn = filename;

% Find information from filename
FileNameIndex = strfind(filename,'.');
ProjectID = filename(1:(FileNameIndex(1)-1));
SubjectID = filename((FileNameIndex(1)+2):(FileNameIndex(2)-1));
DateRec   = filename((FileNameIndex(2)+1):(FileNameIndex(3)-1));
Condition = filename((FileNameIndex(3)+1):(FileNameIndex(4)-1));

% and load file
disp('Filename:')
disp(filename)
disp('File loading... Please Wait')
filename = [filepath filename];
if(ReadSegmentFlag)
    EEG = pop_readegi(filename,[1]);
    ReadSegment = input('Read samples? (Specify as [Start:End] (in seconds) - or click enter to read full signal)');
    if(~isempty(ReadSegment))
        ReadSegment = [(ReadSegment(1)*EEG.srate+1):(ReadSegment(end)*EEG.srate+1)];
        disp('Reading file.... Please Wait')
        EEG = pop_readegi(filename, ReadSegment);
    else
        EEG = pop_readegi(filename);
    end
else
    EEG = pop_readegi(filename);
end

% warning('Loading HGSN channel locations - this layout may not be correct for all systems!')
% switch EEG.nbchan
%     case 129
%         EEG.chanlocs = readlocs('GSN-HydroCel-129.sfp');
%         EEG.ref = 129;
%     case 257
%         EEG.chanlocs = readlocs('GSN-HydroCel-257.sfp');
%         EEG.ref = 257;
% end
EEG = eeg_checkset(EEG);


RawSignal = NBTSignal(EEG.data,EEG.srate, SubjectID, 0, EEG.ref, DateRec, Condition, 'ReadEGIrawScript', [], 'EGI',ProjectID,[]);
RawSignalInfo = nbt_CreateInfoObject(fn, 'raw', EEG.srate, RawSignal);
EEG.setname = RawSignalInfo.file_name;
EEG.NBTinfo = RawSignalInfo;
EEGtmp=rmfield(EEG,'NBTinfo');
EEGtmp.data = [];
RawSignalInfo.Interface.EEG=EEGtmp;
clear EEGtmp

disp('Writing to disk... Please Wait')
filename = [filename(1:(end-3)) 'mat'];
save (([filename]), 'RawSignal', 'RawSignalInfo')
disp('File saved')
end