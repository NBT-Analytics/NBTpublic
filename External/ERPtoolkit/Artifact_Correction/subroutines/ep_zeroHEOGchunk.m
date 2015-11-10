function [outputLog] = ep_zeroHEOGchunk(inFile, startChunk, endChunk, badDataCriteria, badChans, eog, theSubject);
% [outputLog] = ep_zeroHEOGchunk(inFile, startChunk, endChunk, badDataCriteria, badChans, eog, theSubject);
%	Detects horizontal eye movements and zeroes the trial out.
%
%Inputs
%	inFile:     filename (not including the .mat suffix or chunk number.  e.g., "NT5") and sourcepath.
%	startChunk: starting chunk (usually 1)
%   endChunk:   ending chunk
%   badDataCriteria:  Criteria for detecting bad data.
%       .window:    moving average window for smoothing
%       .minmax:    difference from minimum to maximum for bad channel
%       .trialminmax:  difference from minimum to maximum for bad trial
%       .badnum:    percent of bad channels exceeded to declare bad trial, rounding down
%       .hminmax:   difference from minimum to maximum for bad horizontal EOG
%       .neighbors: number of electrodes considered to be neighbors
%       .badchan:   maximum microvolt difference allowed from best matching neighbor
%       .maxneighbor:   maximum microvolt difference allowed from best matching neighbor
%       .blink:     threshold correlation with blink template, 0 to 1
%       .detrend:   1 to detrend
%       .badtrials: percentage of good trials chan is bad to declare a channel globally bad
%       .replace:   1 to interpolate bad channels from neighbors.
%       .noadjacent:1 to not allow adjacent bad channels (trial or subject declared bad)
%   badChans:   list of globally bad channels.  Will be set to a flat line.
%   eog:        EOG channels.
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
% bugfix 10/31/09 JD
% Crash when more than one chunks and they have different numbers of trials.
%
% modified 2/11/10 JD
% Will now work with subject average files with multiple subjects.
% badTrial no longer initialized to zero.
%
% bugfix 3/9/10 JD
% Bad trials field misnamed and hence horizontal eyebelink detection not having any effect.
% Fixed crash when gluing together separate chunks.

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

msg='Detecting horizontal eye movements.';
disp(msg);
outputLog=[];

for chunk = startChunk:endChunk
    eval(['load ''' deblank(inFile) '''-' num2str(chunk) '.mat']);
    numSamples=length(dataChunk.timeNames);
    moveAverageWindow=badDataCriteria.window/(1000/dataChunk.Fs); %samples width of window
    numTrials = length(dataChunk.cellNames);
    badTrialNum{chunk}=dataChunk.analysis.badTrials;

    for trial=1:numTrials
        theData=dataChunk.data(:,:,trial,theSubject);
        %moving average window smoothing
        if badDataCriteria.window == 0
            theFilteredData=theData;
        else
            theFilteredData=filter((1/moveAverageWindow)*ones(moveAverageWindow,1),1,theData')';
        end;
        %detect bad channels
        if max(abs(theFilteredData(eog.LHEOG)-theFilteredData(eog.RHEOG)))>=badDataCriteria.hminmax
            theData=0;
            badTrialNum{chunk}(theSubject,trial)=1;
        end;
    end;
    dataChunk.data(:,:,trial,theSubject)=theData;
    dataChunk.analysis.badTrials=badTrialNum{chunk};
end;

eval (['save ''' inFile '''-' num2str(chunk) '.mat dataChunk']);

totBadTrials=[];
for chunk=startChunk:endChunk
    totBadTrials=[badTrialNum{chunk} totBadTrials];
end;
numBadTrials=sum(totBadTrials(theSubject,:)');
if numBadTrials ==1
    outputLog{1}=strvcat(outputLog, 'There was 1 horizontal eye movement trial.');
else
    outputLog{1}=strvcat(outputLog, ['There were ' num2str(numBadTrials) ' horizontal eye movement trials.']);
end;

