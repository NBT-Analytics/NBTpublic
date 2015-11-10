function [outputLog] = ep_markBadDataChunks(inFile, startChunk, endChunk, badChans, theSubject);
% ep_markBadDataChunks(inFile, startChunk, endChunk, badChans, theSubject);
%	Marks bad channels and trials with a flat line interrupted by a huge spike for another program like NetStation to fix.
%
%Inputs
%	inFile:     filename (not including the .mat suffix or chunk number.  e.g., "NT5") and sourcepath.
%	startChunk: starting chunk (usually 1)
%   endChunk:   ending chunk
%   badChans:   list of globally bad channels.  Will be set to a flat line.
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
% modified 4/17/09 JD
% Dropped eloc as separate input parameter (now part of data).
%
% bugfix 12/8/09 JD
% Fixed crash when there are bad channels.  Thanks to Alex Lamey.
%
% modified 2/11/10 JD
% Will now work with subject average files with multiple subjects.
% Gets bad channel and bad trial info from the data chunk rather than from the function call.

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

msg='Marking bad channels and trials.';
disp(msg);
outputLog=msg;

trialCount=1;
for chunk = startChunk:endChunk
    eval(['load ''' deblank(inFile) '''-' num2str(chunk) '.mat']);
    numSamples=length(dataChunk.timeNames);
    numTrials = length(dataChunk.cellNames);
    numChans=length(dataChunk.chanNames);
    spike=[1000 zeros(1,numSamples-1)];

    badChanNum=dataChunk.analysis.badChans;
    badTrialNum=dataChunk.analysis.badTrials;

    for trial=1:numTrials
        if badTrialNum(trial+trialCount-1)
            dataChunk.data(:,:,trial,theSubject)=repmat(spike,numChans,1);
        else
            theData=dataChunk.data(:,:,trial,theSubject);
            trialBadChans=find(badChanNum(1,trialCount+trial-1,:));
            trialGoodChans=setdiff([1:numChans],trialBadChans);
            theData(trialBadChans,:)=repmat(spike,length(trialBadChans),1);
            dataChunk.data(:,:,trial,theSubject)=theData;
        end;
    end;
    eval (['save ''' inFile '''-' num2str(chunk) '.mat dataChunk']);
    trialCount=trialCount+numTrials;
end;
