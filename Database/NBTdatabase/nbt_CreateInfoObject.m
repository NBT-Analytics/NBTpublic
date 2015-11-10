
% Info = nbt_CreateInfoObject(filename, FileExt, Fs, NBTSignalObject)
%
% Usage:
% nbt_CreateInfoObject(filename, FileExt)
% or 
% nbt_CreateInfoObject(filename, FileExt, Fs)
% or
% nbt_CreateInfoObject(filename, FileExt, Fs, NBTSignalObject)
%
% See also:
%   nbt_Info

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

function Info = nbt_CreateInfoObject(filename, FileExt, Fs, NBTSignalObject);

error(nargchk(2,4,nargin))
disp('Creating Info object')

file_name_format= '<ProjectID>.S<SubjectID>.<Date in YYMMDD>.Condition';

if(~exist('Fs'))
    Fs = input('Please, specify the sampling frequency? ');
end
try
    IDdots = strfind(filename,'.');
    if(~isempty(FileExt))
        Info = nbt_Info(filename(1:(strfind(filename,FileExt)-2)),file_name_format,filename((IDdots(3)+1):(IDdots(4)-1)), ...
            filename((IDdots(2)+1):(IDdots(3)-1)),[],[],[],str2double(filename((IDdots(1)+2):(IDdots(2)-1))),filename(1:(IDdots(1)-1)),[],[],[],[],[],[]);
    else
        Info = nbt_Info(filename,file_name_format,filename((IDdots(3)+1):end), ...
            filename((IDdots(2)+1):(IDdots(3)-1)),[],[],[],str2double(filename((IDdots(1)+2):(IDdots(2)-1))),filename(1:(IDdots(1)-1)),[],[],[],[],[],[]);
    end
catch
    filename = input('Please write filename in correct format, <ProjectID>.S<SubjectID>.<Date in YYMMDD>.Condition ','s');
    IDdots = strfind(filename,'.');
    if(~isempty(FileExt))
        Info = nbt_Info(filename(1:(strfind(filename,FileExt)-2)),file_name_format,filename((IDdots(3)+1):(IDdots(4)-1)), ...
            filename((IDdots(2)+1):(IDdots(3)-1)),[],[],[],str2double(filename((IDdots(1)+2):(IDdots(2)-1))),filename(1:(IDdots(1)-1)),[],[],[],[],[],[]);
    else
        Info = nbt_Info(filename,file_name_format,filename((IDdots(3)+1):end), ...
            filename((IDdots(2)+1):(IDdots(3)-1)),[],[],[],str2double(filename((IDdots(1)+2):(IDdots(2)-1))),filename(1:(IDdots(1)-1)),[],[],[],[],[],[]);
    end
end
Info.converted_sample_frequency = Fs;

if(exist('NBTSignalObject'))
    Info.Info = NBTSignalObject.Info;
    try
        Info.Interface.EEG = Info.Info.EEG;
        Info.Info.EEG = [];
    catch
    end
end
Info.LastUpdate = datestr(now);
end