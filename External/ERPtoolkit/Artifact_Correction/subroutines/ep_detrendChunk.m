function [outputLog] = ep_detrendChunk(inFile, startChunk, endChunk, theSubject);
% [outputLog] = ep_detrendChunk(inFile, startChunk, endChunk, theSubject);
%	Detrends the data on a trialwise basis, reading in a chunk at a time.
%
%Inputs
%	inFile:     filename (not including the .mat suffix or chunk number.  e.g., "NT5") and sourcepath.
%	startChunk: starting chunk (usually 1)
%   endChunk:   ending chunk
%   theSubject: which subject of the file is being processed.
%
%   The input chunks include: dataChunk in EP data format.
%
%Outputs
%   outputLog: output messages from bad data process.
%
%   Updated output chunks: dataChunk in EP data format.
%
% History:
%
% by Joseph Dien (2/09)
% jdien07@mac.com
%
% modified 3/14/09 JD
% Changed to use EP format data to provide more flexibility with I/O functions.
%
% modified 2/11/10 JD
% Will now work with subject average files with multiple subjects.

%     Copyright (C) 1999-2010  Joseph Dien
%
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
%
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
%
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <http://www.gnu.org/licenses/>.

msg=['Detrending.'];
disp(msg);
outputLog{1}=msg;

for chunk = startChunk:endChunk
    eval(['load ''' deblank(inFile) '''-' num2str(chunk) '.mat']);
    numSamples=length(dataChunk.timeNames);
    numTrials = length(dataChunk.cellNames);

    for trial=1:numTrials
        theData=dataChunk.data(:,:,trial,theSubject);
        theData=detrend(theData')';
        chunkData.data(:,:,trial,theSubject)=theData;
    end;
    eval (['save ''' inFile '''-' num2str(chunk) '.mat dataChunk']);
end;