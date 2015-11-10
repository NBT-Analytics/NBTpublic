function [outputLog, globalBadChans, totBadChanNum, totBadTrialNum] = ep_detectBadDataChunk(inFile, startChunk, endChunk, badDataCriteria, globalBadChans, baseline, theSubject);
% [outputLog, globalBadChans, totBadChanNum, totBadTrialNum] = ep_detectBadDataChunk(inFile, startChunk, endChunk, badDataCriteria, globalBadChans, baseline, theSubject);
%	Detects bad channels and bad trials.  Bad channels have a
%	minimum/maximum difference over threshold.  Also, channels whose maximum difference from neighboring electrodes is
%   no smaller than a certain threshold even from the neighboring electrode with the smallest difference is declared
%   bad.  Trials with too many bad channels (including globally bad channels) declared bad trials.  Also,
%	trials with bad channels next to another bad channel (but not globally bad channels) declared bad trials
%   because they usually represent trials with generalized artifacts rather than isolated bad channels.
%   Channels that are bad on too many of the good trials are declared globally bad.
%   Criteria settings determine whether each of these considerations are applied and to what degree.
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
%   globalBadChans:   list of globally bad channels.  Will be set to a flat line.
%   theSubject: which subject of the file is being processed.
%
%   The input chunks include: dataChunk in EP data format.
%
%Outputs
%   outputLog: output messages from bad data process.
%   globalBadChans:   updated list of globally bad channels.
%   totBadChanNum:  Total list of bad channels (subject,trial,channel).
%   totBadTrialNum: Total list of bad trials.
%
%   Updated output chunks: dataChunk in EP data format.
%
% History:
%
% by Joseph Dien (2/09)
% jdien07@mac.com
%
% modified 3/19/09 JD
% Changed to use EP format data to provide more flexibility with I/O functions.
%
% modified 4/17/09 JD
% Treats flat channels as bad data unless they are a reference channel which is flat over entire dataset.
% Dropped eloc as separate input parameter (now part of data).
%
% modified 5/28/09 JD
% no longer zeroes out bad channels and trials, just notes them for later correction.
%
% bugfix 6/11/09 JD
% Was always applying no adjacent constraint even when option was turned off.
%
% bugfix 6/22/09 JD
% if no baseline set then will not try to subtract it (avoiding divide by zero error warning)
% Fix to badChanNum not being in right format, causing file not to be written out.
%
% modified & bugfix 9/18/09 JD
% Added support for multiple refChans to deal with mean mastoid data where the presence of the two reference channels (correlated -1)
% was causing ICA problems.  Trial specs coded only for single_trial data.
% Commented out setting bad trial code for "edit" field as was causing crash for non-EGIS files and
% not being used in any case.
% Was identifying wrong channel as bad when there was a flat channel and there was a reference channel with a lower
% number.
%
% bugfix 11/21/09 JD
% Replaced "union" commands with "unique" commands because certain situations caused the "union" command to crash in
% Matlab 2007.
%
% bugfix 12/3/09 JD
% Fix for bug where channel 1 would be marked as bad in too many trials if there was only one globally bad channel.
%
% modified 2/7/10 JD
% Changed bad channel field to negative numbers for still bad channels.
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

msg=['Detecting bad data.'];
disp(msg);
outputLog=[];

totBadChanNum=[];
totBadTrialNum=[];
for chunk = startChunk:endChunk
    eval(['load ''' deblank(inFile) '''-' num2str(chunk) '.mat']);
    elecDistances=ep_closestChans(dataChunk.eloc);
    refChan= find(strcmp('REF',cellstr(dataChunk.chanTypes)));
    
    numSamples=length(dataChunk.timeNames);
    numChans=length(dataChunk.chanNames);
    nonRefChans=setdiff([1:numChans],refChan);
    
    moveAverageWindow=badDataCriteria.window/(1000/dataChunk.Fs); %samples width of window
    numTrials = length(dataChunk.cellNames);
    badChanNum{chunk}=dataChunk.analysis.badChans;
    badTrialNum{chunk}=dataChunk.analysis.badTrials;
    
    badChanNum{chunk}(theSubject,:,globalBadChans)=-1;
    numRegressors=min(badDataCriteria.neighbors,numChans-1);
    neighbors=zeros(numChans,numRegressors);
    for chan=1:numChans
        [E IX]=sort(elecDistances(chan,:));
        neighbors(chan,:)=IX(2:numRegressors+1);
    end;
    
    chanDiffs=zeros(1,numChans);
    for trial=1:numTrials
        theData=squeeze(dataChunk.data(:,:,trial,theSubject));
        
        %moving average window smoothing
        if badDataCriteria.window == 0
            theFilteredData=theData;
        else
            theFilteredData=filter((1/moveAverageWindow)*ones(moveAverageWindow,1),1,theData')';
        end;
        
        %channel bad if too much change over course of trial
        trialBadChans=find(abs(max(theFilteredData')-min(theFilteredData'))>=badDataCriteria.minmax);
        %channel bad if flat and not the reference but reference must be flat over entire dataset
        trialBadChans=unique([trialBadChans,nonRefChans(find(~std(theFilteredData(nonRefChans,:)')))]);
        
        trialGoodChans=setdiff([1:numChans],[trialBadChans globalBadChans]); %good channels in the trial
        
        if length(trialGoodChans) > 1
            %channel bad if too different from neighbors
            if ~isempty(baseline)
                baselineData=theFilteredData-diag(mean(theFilteredData(:,baseline),2))*ones(size(theFilteredData));
            else
                baselineData=theFilteredData;
            end;
            for chan=trialGoodChans
                chanDiffs(chan)=min(max(abs(baselineData(setdiff(trialGoodChans,chan),:)-repmat(baselineData(chan,:),length(trialGoodChans)-1,1)),[],2));
            end;
            trialBadChans=unique([find(chanDiffs >= badDataCriteria.maxneighbor), trialBadChans]); %bad channels due to neighbors
        end;
        
        badChanNum{chunk}(theSubject,trial,trialBadChans)=-1;
        
        %too many bad channels?
        badTrial=0;
        if badDataCriteria.badnum ~=0
            if length(unique([trialBadChans, globalBadChans]))>=floor(numChans*(badDataCriteria.badnum/100))
                theData=0;
                badTrialNum{chunk}(theSubject,trial)=1;
                badTrial=1;
            end;
        end;
        
        %if there are adjacent trial bad channels, trial is bad
        if badDataCriteria.neighbors && badDataCriteria.noadjacent && ~badTrial && ~isempty(trialBadChans) %neighboring bad channels?
            badNeighbors=0;
            for i=1:length(trialBadChans)
                chan=trialBadChans(i);
                if ~isempty(intersect(trialBadChans,neighbors(chan,:)))
                    badNeighbors=1;
                    break
                end;
            end;
            if badNeighbors
                badTrialNum{chunk}(theSubject,trial)=1;
            end;
        end;
        
    end;
end;
totBadChanNum=[totBadChanNum badChanNum{chunk}];
totBadTrialNum=[totBadTrialNum badTrialNum{chunk}];

dataChunk.analysis.badChans=badChanNum{chunk};
dataChunk.analysis.badTrials=badTrialNum{chunk};
eval (['save ''' deblank(inFile) '''-' num2str(chunk) '.mat dataChunk;']);

%are any channels bad in too many trials?
if badDataCriteria.badtrials ~=0
    numTotTrials=length(totBadTrialNum);
    numTotGoodTrials=sum(totBadTrialNum(theSubject,:)==0);
    tooBadChans=find((sum(totBadChanNum(theSubject,find(totBadTrialNum(theSubject,:)==0),:),2)/numTotGoodTrials)>badDataCriteria.badtrials/100)';
    
    totBadChanNum=[];
    totBadTrialNum=[];
    for chunk = startChunk:endChunk
        eval(['load ''' deblank(inFile) '''-' num2str(chunk) '.mat']);
        badChanNum{chunk}(theSubject,:,tooBadChans)=1;
        totBadChanNum=[totBadChanNum badChanNum{chunk}];
        totBadTrialNum=[totBadTrialNum badTrialNum{chunk}];
    end;
end;

globalBadChans=unique([globalBadChans, tooBadChans]);

numBadTrials=sum(totBadTrialNum(theSubject,:)');
meanBadChans=-mean(sum(totBadChanNum(theSubject,find(totBadTrialNum(theSubject,:)==0),:))); %calculate mean bad chans only for good trials
if numBadTrials ==1
    outputLog{1}='There was 1 bad trial.';
else
    outputLog{1}=['There were ' num2str(numBadTrials) ' bad trials.'];
end;
outputLog{end+1}=['For good trials, there was an average of ' num2str(meanBadChans) ' bad channels per trial.'];
