function [badChans shortChans outputLog]=ep_detectBadChans(EPdata, badDataCriteria, theSubject);
%  [badChans shortChans outputLog]=ep_detectBadChans(EPdata, badDataCriteria, theSubject);
%       Detects bad channels by identifying ones that cannot be readily
%       predicted by the neighboring channels and by detecting flat data channels.
%       Also notes shorted channels.
%
%Inputs:
%  EPdata         : Structured array with the data and accompanying information.  See readData.
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
%   theSubject: which subject of the file is being processed.
%
%Outputs:
%  badChans : List of bad channels.
%  shortChans: List of shorted channels.
%  outputLog: output messages from bad channel detection process

%History:
%  by Joseph Dien (2/8/09)
%  jdien07@mac.com
%
% modified 3/14/09 JD
% Changed to use EP format data to provide more flexibility with I/O functions.
%
% modified 5/15/09 JD
% Treats flat channels as bad data and excludes from bad channel detection routine.
% Dropped eloc as separate input parameter (now part of data).
% Flat channel not bad if it is the reference channel.
%
% modified 9/4/09 JD
% Added support for multiple refChans to deal with mean mastoid data where the presence of the two reference channels (correlated -1)
% was causing ICA problems.
%
% modified 10/28/09 JD
% Added detection of channels perfectly correlated with a reference channel and which were therefore flat prior to rereferencing.
%
% modified 11/12/09 JD
% Correlated channels can be only nearly perfect (e.g., .9999) and still trigger bad channel code, to account for rounding errors etc.
%
% bugfix 11/20/09 JD
% Replaced "union" commands with "unique" commands because certain situations caused the "union" command to crash in
% Matlab 2007.
%
% modified & bugfix 12/3/09 JD
% Detects non-reference channels that are perfectly correlated and identifies them as bad channels as they must be
% shorted together.  Fixed bug where test of correlation with reference only detecting +1 correlation, not -1 correlation.
% Fixed bug where if there is an explicit reference channel and it is flat, then all reference channels marked bad and
% real bad channels are no longer marked bad.
% Don't apply correlated neighbors test to the reference channels as distant reference channels will always be labeled
% bad.
%
% modified & bugfix 2/24/10 JD
% Now works on average files.
% Fixed bug where neighboring channels for determing whether a channel is not correlating with its neighbors sometimes not chosen
% correctly, which could lead to too many channels being dubbed globally bad.
% No longer treating shorted channels as being bad (too conservative).  Instead just displaying a warning message.
% If there are two reference channels (as in mean mastoids), then no longer require that they have a -1 correlation as one may just be bad.
% If there are two reference channels (as in mean mastoids), then they are still marked as bad channels if they are
% flat.
% Added log output.
% When there are shorted channels, prints out the channel pairs.

badChans{1}=-1;
outputLog={};

if nargin < 3
    theSubject =1;
end;

if strcmp(EPdata.dataType,'factors')
    msg='This function does not support factor files.';
    disp(msg);
    outputLog{end+1}=msg;
    badChans{1}=-1;
    return;
end;

elecDistances=ep_closestChans(EPdata.eloc);

numSubs=length(EPdata.subNames);
shortChans=[];
numChans=length(EPdata.chanNames);
if length(EPdata.eloc) ~= numChans
    msg='Error: The number of channels in the electrode coordinates file is different from that of the data.';
    disp(msg);
    outputLog{end+1}=msg;    
    badChans{1}=-1;
    return;
end;

testData=reshape(EPdata.data(:,:,:,theSubject),numChans,[]);
normData=pinv(diag(std(testData,0,2)))*testData;
normData=normData-diag(mean(normData,2))*ones(size(normData));
badChans=find(~std(normData')); %flat channels are bad.
goodChans=find(std(normData'));
elecDistances(badChans,:)=inf;
elecDistances(:,badChans)=inf;
refChan= find(strcmp('REF',cellstr(EPdata.chanTypes)));

if isempty(goodChans)
    msg='Error: No good channels left.';
    disp(msg);
    outputLog{end+1}=msg; 
    badChans{1}=-1;
    return;
end;

corrs=corrcoef([testData']);
corrSigns=sign(corrs);
corrs=corrSigns.*ceil(abs(corrs)*1000)/1000;

%look for bad channels that are perfectly correlated with each other and must therefore be shorted together.

goodNonRefChans=setdiff(goodChans,refChan);

shortPairs=[];
for chan1= 1:length(goodNonRefChans)
    theChan1= goodNonRefChans (chan1);
    for chan2=chan1+1:length(goodNonRefChans)
        theChan2= goodNonRefChans (chan2);
        if abs(corrs(theChan1, theChan2))== 1
            shortChans=unique([shortChans theChan1, theChan2]);
            shortPairs=[shortPairs EPdata.chanNames{theChan1} '-' EPdata.chanNames{theChan2} '; '];
        end;
    end;
end;
if ~isempty(shortPairs)
    msg=['Warning: shorted channels: ' shortPairs];
    disp(msg);
    outputLog{end+1}=msg;
end;

%look for bad channels that are not correlated with other channels
numRegressors=min(badDataCriteria.neighbors,length(goodChans)-1);
neighbors=zeros(numChans,numRegressors);
for chan=goodChans
    [E IX]=sort(elecDistances(chan,goodChans));
    neighbors(chan,:)=goodChans(IX(2:numRegressors+1));
end;

chanPred=zeros(numChans,1);
for chan=goodChans
    Y=normData(chan,:)';
    X=normData(neighbors(chan,:),:)';
    R=corrcoef([Y X]);
    R=R(2:end,1);
    B=[ones(size(normData,2),1) X]\Y;
    chanPred(chan)=sqrt(sum(B(2:end).*R));
end;

nonRefGoodChans=setdiff(goodChans,refChan);
badChans=[badChans nonRefGoodChans(find(chanPred(nonRefGoodChans) < badDataCriteria.badchan))]; %don't check ref chans for being bad by local channel predictability

if length(refChan) == 1
    if std(normData(refChan,:)')==0
        badChans=setdiff(badChans,refChan); %flat channel is not bad if it is the reference channel
    end;
end;

goodChans=setdiff(goodChans,badChans);

if isempty(goodChans)
    msg='Error: No good channels left.';
    disp(msg);
    outputLog{end+1}=msg; 
    badChans{1}=-1;
    return;
end;

%look for bad channels that are perfectly correlated with the reference channel(s) and were therefore flat prior to
%rereferencing.

if length(refChan) > 2
    msg='There are more than two reference channels indicated.';
    disp(msg);
    outputLog{end+1}=msg;
    badChans{1}=-1;
    return;
elseif length(refChan) == 2
    if (corrs(refChan(1),refChan(2)) ~= -1) && isempty(intersect(refChan,badChans))
        msg=['The two reference channels should have a perfect inverse correlation and do not (' num2str(corr(refChan(1),refChan(2))) ') so something is wrong.'];
        disp(msg);
        outputLog{end+1}=msg;
        badChans{1}=-1;
        return;
    end;
    refCorrs=abs(corrs(refChan(1),:));
    badChans=unique([badChans,setdiff(find(refCorrs == 1),refChan)]);
elseif length(refChan) == 1
    refCorrs=abs(corrs(refChan(1),:));
    badChans=unique([badChans,setdiff(find(refCorrs == 1),refChan)]);
end;

goodChans=setdiff(goodChans,badChans);

if isempty(goodChans)
    msg='Error: No good channels left.';
    disp(msg);
    outputLog{end+1}=msg;
    badChans{1}=-1;
    return;
end;





