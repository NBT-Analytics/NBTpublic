function [outputLog] = ep_replaceBadDataChunks(inFile, startChunk, endChunk, badChans, theSubject, butterflyFig);
% ep_replaceBadDataChunks(inFile, startChunk, endChunk, badChans, theSubject, butterflyFig);
%	Interpolates bad channels.
%
%Inputs
%	inFile:     filename (not including the .mat suffix or chunk number.  e.g., "NT5") and sourcepath.
%	startChunk: starting chunk (usually 1)
%   endChunk:   ending chunk
%   badChans:   list of globally bad channels.  Will be set to a flat line.
%   butterflyFig:  the handle for the output figure.  Otherwise, will open a new figure.
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
% by Joseph Dien (4/9/09)
% jdien07@mac.com
%
% Based on markBadDataChunks.
%
% modified 4/17/09 JD
% Dropped eloc as separate input parameter (now part of data).
%
% modified 5/30/09 JD
% Ouputs to butterly figure.
%
% bugfix 7/14/09 JD
% Fixed occasional crash in bad channel replacement code.
%
%  bugfix 9/14/09 JD
%  Don't bother to go through the time points of a trial if none of the channels are bad.  Was slowing things down.
%
% modified 10/28/09 JD
% Added option to disable preprocessing figure for low memory situations.
%
%  bugfix 12/8/09 JD
%  Bad channels incorrectly interpolated (the x & y coordinates were reversed).
%
% modified 2/7/10 JD
% Changed bad channel field to negative numbers for still bad channels.
%
% modified 2/11/10 JD
% Will now work with subject average files with multiple subjects.
% analysis fields no longer optional.
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

msg='Replacing bad channels.';
disp(msg);
outputLog=msg;

if nargin < 6
    butterflyFig=figure('Name','Bad Channel Correction','NumberTitle','off');
end;

for chunk = startChunk:endChunk
    warning off MATLAB:griddata:DuplicateDataPoints
    fprintf('%60s\n',' ' );
    trialCount=1;
    eval(['load ''' deblank(inFile) '-' num2str(chunk) '.mat''']);
    
    if length(dataChunk.facNames) > 1
        error('This function is not intended for application to factor data.');
    end;
    
    maxRad=0.5;
    GRID_SCALE=67;
    [y,x] = pol2cart(([dataChunk.eloc.theta]/360)*2*pi,[dataChunk.eloc.radius]);  % transform electrode locations from polar to cartesian coordinates
    y=-y; %flip y-coordinate so that nose is upwards.
    plotrad = min(1.0,max([dataChunk.eloc.radius])*1.02);            % default: just outside the outermost electrode location
    plotrad = max(plotrad,0.5);                 % default: plot out to the 0.5 head boundary
    x = x*(maxRad/plotrad);
    y = y*(maxRad/plotrad);
    
    xmin = min(-maxRad,min(x));
    xmax = max(maxRad,max(x));
    ymin = min(-maxRad,min(y));
    ymax = max(maxRad,max(y));
    
    x=round(((x/(xmax-xmin))*GRID_SCALE)+ceil(GRID_SCALE/2));
    y=round(((y/(ymax-ymin))*GRID_SCALE)+ceil(GRID_SCALE/2));
    
    numSamples=length(dataChunk.timeNames);
    numTrials = length(dataChunk.cellNames);
    numChans=length(dataChunk.chanNames);
    displayPeriod=numTrials*numSamples;    %Number of timepoints to graph in display.
    badData=zeros(numChans,displayPeriod);
    
    badChanNum=dataChunk.analysis.badChans;
    badTrialNum=dataChunk.analysis.badTrials;
    
    if nargin < 6
        trialdata=reshape(dataChunk.data(:,:,:,theSubject),numChans,[]);
        figure(butterflyFig(chunk));
        subplot(3,1,1), plot([1:displayPeriod],trialdata(:,1:displayPeriod));
        axis([1 displayPeriod -200 200])
        title([deblank(inFile) '-' num2str(chunk)],'Interpreter','none');
    end;
    
    for trial=1:numTrials
        if strcmp(dataChunk.dataType,'single_trial')
            fprintf('%s%-60s',repmat(sprintf('\b'),1,60),sprintf('%s%4d','Working on trial# ', trial+trialCount-1))
        end;
        if badTrialNum(theSubject,trial+trialCount-1)
            badData(:,(trial-1)*numSamples+1:trial*numSamples)=dataChunk.data(:,:,trial,theSubject);
            dataChunk.data(:,:,trial,theSubject)=0; %set bad trials to flat lines
        else
            trialBadChans=find(badChanNum(theSubject,trialCount+trial-1,:));
            if ~isempty(trialBadChans)
                trialGoodChans=setdiff([1:numChans],trialBadChans);
                badData(trialBadChans,(trial-1)*numSamples+1:trial*numSamples)=dataChunk.data(trialBadChans,:,trial,theSubject);
                for sample=1:numSamples
                    [Xi,Yi,Zi] = griddata(x(trialGoodChans),y(trialGoodChans),dataChunk.data(trialGoodChans,sample,trial,theSubject),[1:GRID_SCALE]',[1:GRID_SCALE],'v4');
                    %v4 interpolates to the edge of the box.  With other interpolation options, if a bad channel is at the edge of the montage then it
                    %would just be NaN.
                    for theBadchan=1:length(trialBadChans)
                        badchan=trialBadChans(theBadchan);
                        dataChunk.data(badchan,sample,trial,theSubject)=Zi(y(badchan),x(badchan));
                    end;
                end;
                %change badChan field to positive to indicate those channels have been corrected.
                dataChunk.analysis.badChans(theSubject,trialCount+trial-1,trialBadChans)=abs(dataChunk.analysis.badChans(theSubject,trialCount+trial-1,trialBadChans));
            end;
        end;
    end;
    fprintf('%60s\n',' ' );
    
    trialdata=reshape(dataChunk.data(:,:,:,theSubject),numChans,[]);
    
    if ~isempty(butterflyFig)
        if nargin < 6
            figure(butterflyFig(chunk));
            subplot(3,1,2), plot([1:displayPeriod],badData);
            axis([1 displayPeriod -200 200])
            title('bad data','Interpreter','none');
            subplot(3,1,3), plot([1:displayPeriod],trialdata);
            axis([1 displayPeriod -200 200])
            title('with bad channels replaced and bad trials zeroed','Interpreter','none');
        else
            figure(butterflyFig(chunk));
            subplot(8,1,7), plot([1:displayPeriod],badData);
            axis([1 displayPeriod -200 200])
            title('bad data','Interpreter','none');
            subplot(8,1,8), plot([1:displayPeriod],trialdata);
            axis([1 displayPeriod -200 200])
            title('with bad channels replaced and bad trials zeroed','Interpreter','none');
        end;
    end;
    
    drawnow
    
    eval (['save ''' inFile '-' num2str(chunk) '.mat'' dataChunk']);
    if nargin < 6
        try
            eval (['print -f' num2str(butterflyFig(chunk)) ' -djpeg ''' inFile '''-' num2str(chunk) 'blink.jpg']);
        catch
            disp('Couldn''t save a copy of the bad channel correction figure.  Perhaps your version of Matlab is not current.');
        end;
    end;
    
    trialCount=trialCount+numTrials;
end;
fprintf('%s\r',' ' );
warning on MATLAB:griddata:DuplicateDataPoints

if nargin < 6
    close(butterflyFig);
end;

