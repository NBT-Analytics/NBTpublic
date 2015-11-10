function [data] = unmultiplex(obj, muxData, fs)
% UNMULTIPLEX - Unmultiplex multiplexed data channel
%
% data = unmultiplex(muxSensors, muxData)
%
% Where
%
% MUXDATA is a 1xL numeric matrix, the multiplexed data channel
%
% See also sensors.mux.mux


MARGIN = 6; % In samples
MAX_CALIB_ERR = 1e-6; % Maximum calibration error in centigrades

% Duration of eash slot in samples
slotDurSecs  = 1e-3*obj.CycleDur/obj.NbSlots;
slotDurSampl = slotDurSecs*fs;

if slotDurSampl < 3*MARGIN,
    % This is required to have security margin when calculating the signal
    % value in each slot
    error('Slots must have a duration of at least 10 samples');
end

% How many cycles are there in this data chunk?
nbCycles = floor(numel(muxData)/(obj.CycleDur*1e-3*fs));

% We need to find nbCycles peaks in the diff
%diffData = abs(diff(muxData));
diffData = [0 diff(muxData)];

% Ensure that there is just one transition per slot
intSlotDurSampl = floor(slotDurSampl);
halfSlotDur = max(1, floor(slotDurSampl/2));
for i = intSlotDurSampl:numel(muxData)
   thisIdx = i-halfSlotDur+1:i;
   cond = abs(diffData(thisIdx)) < max(abs(diffData(thisIdx)));
   diffData(thisIdx(cond)) = 0;
end

% Look for the locations of the transitions between the first and second
% calibration slots. This search is based on the following heuristics and
% may not be completely robust:
%
% 0) The peak P1 must be negative
%
% 1) Distance between P1, P2, P3 should be very close to the slot
% duration
%
% 2) The transition corresponds to a peak (P1) followed by a peak (P2) of
% opposite polarity, which itself is followed by a peak (P3) of opposite
% polarity.
%
% 3) P1, P2 and P3 should be of a similar order of magnitude
%
% 4) MUX channel values between P2 and P3 (X3) should be considerably 
% closer to zero than values before P1 (X1), values between P1 and P2 (X2) 
% and values after P3 (X4)
%
% 5) After fitting a polynomial to (X1, 40), (X2, 10), (X3, 25) the error
% should be 'very' small.
%
% 6) X2/X1 should be between 9.75 and 1.25

% Scan through all the peaks and pick those that fulfill the heuristics
% above

% We would expect at least this number of peaks
nbPeaks = obj.NbSlots*numel(diffData)/(obj.CycleDur*fs);
th = prctile(abs(diffData), 100*(1-nbPeaks/numel(diffData)));
pos = find(abs(diffData) > 0.1*th);

isPeak = true(1, numel(pos));

intSlotDurSampl = floor(slotDurSampl);

for i = 1:numel(pos)-4
    
    P1 = pos(i);
    P2 = pos(i+1);
    P3 = pos(i+2);
    P = [P1 P2 P3];
    
    % heuristic 0
    if diffData(P1) < 0,
        isPeak(i) = false;
        continue;
    end
        
    % heuristic 1    
    Pdiff = diff(P);
    if any(Pdiff > 1.1*slotDurSampl | Pdiff < 0.9*slotDurSampl),
        isPeak(i) = false;
        continue;
    end
    
    % heuristic 2
    if sign(diffData(P1)*diffData(P2)) > 1 || ...
            sign(diffData(P2)*diffData(P3)) > 1
        isPeak(i) = false;
        continue;
    end   
    
    % heuristic 3
    meanP = mean(abs(P));
    if any(P < 0.25*meanP) || any(P > 4*meanP)
        isPeak(i) = false;
        continue;
    end    
    
    % heuristic 4
    X1 = median(muxData(max(1, P1-intSlotDurSampl):P1));
    X2 = median(muxData(P1:P2));
    X3 = median(muxData(P2:P3));
    X4 = median(muxData(P3:min(numel(muxData), P3+intSlotDurSampl)));
    if X3 > abs(0.1*X1) || X3 > abs(0.1*X2) || (X3 > abs(0.1*X4))
        isPeak(i) = false;
        continue;
    end
    
    % heuristic 5
    [p, ~, mu] = polyfit([X1;X2;X3], [40;10;25], 2);
    y = polyval(p, [X1;X2;X3], [], mu);
    if any(abs(y-[40;10;25]) > 1e-3),
        isPeak(i) = false;
    end
    
    % heuristic 6
    if abs(X2/X1) > 1.25 || abs(X2/X1) < 0.75
        isPeak(i) = false;
    end
        
end

isPeak(numel(pos)-3:end) = false;

if ~any(isPeak),
    warning('mux:MissingCycleOnsets', ...
        ['Missing cycle onsets in this block of %d secs: ' ...
        'Setting all MUX channels to zeroes'], round(numel(muxData)/fs));
    data = zeros(numel(obj.SignalSlotIdx), numel(muxData));
    return;
end

peakLoc = pos(isPeak);

missingPeaks = nbCycles  - numel(peakLoc);
if missingPeaks == -1,
    peakLoc(end) = [];
elseif missingPeaks < 0,
    error('I found more cycles (%d) than expected (%d)!', ...
        numel(peakLoc), nbCycles);
end

nbCycles = numel(peakLoc);


% Note: do not test that the distance between cycles is constant because
% the recording may have been interrupted, therefore violating the constant
% cycle-distance assumption

% Mapping between calibration values and umux signal values
calibVal = nan(numel(obj.CalibSlotIdx), nbCycles);
for i = 1:numel(obj.CalibSlotIdx)
    
    idx = repmat(round(peakLoc(:)+...
        (obj.CalibSlotIdx(i)-1)*slotDurSampl), 1, ...
        round(slotDurSampl) - 2*MARGIN+1) + ...
        repmat(-round(slotDurSampl)+MARGIN:-MARGIN, numel(peakLoc), 1);
  
    idx(idx < 1 | idx > numel(muxData)) = NaN;

    for j = 1:nbCycles,
        thisIdx = idx(j,~isnan(idx(j,:)));
        if ~isempty(thisIdx),
            calibVal(i, j) = median(muxData(thisIdx));
        end
    end

end

% Replace missing calibration values with median calib values
for i = 1:size(calibVal,1)
   calibVal(i, isnan(calibVal(i,:))) = ...
       median(calibVal(i,~isnan(calibVal(i,:))));
end

% Read data cycle by cycle
signalVal = nan(numel(obj.SignalSlotIdx), nbCycles);
for i = 1:numel(obj.SignalSlotIdx)
    
    idx = repmat(round(peakLoc(:)+...
        (obj.SignalSlotIdx(i)-1)*slotDurSampl), 1, ...
        round(slotDurSampl) - 2*MARGIN+1) + ...
        repmat(-round(slotDurSampl)+MARGIN:-MARGIN, numel(peakLoc), 1);
   
    idx(idx < 1 | idx > numel(muxData)) = NaN;
    
    for j = 1:nbCycles,
        thisIdx = idx(j,~isnan(idx(j,:)));
        if ~isempty(thisIdx),
            signalVal(i, j) = median(muxData(thisIdx));
        end
    end
   
end

% Replace missing values with nearest values
signalVal(isnan(signalVal(:,end)),end) = ...
    signalVal(isnan(signalVal(:,end)), end-1);

signalVal(isnan(signalVal(:,1)),1) = ...
    signalVal(isnan(signalVal(:,1)), 2);

% Transform signal values to temperatures
for i = 1:size(signalVal,2)
    % Calibration polynomial (order 2) for this cycle    
    y = obj.CalibValue';
    x = calibVal(:,i);
    [p, ~, mu] = polyfit(x(:), y(:), 2);
    y2 = polyval(p, x, [], mu);
    
    if max(abs(y2(:)-y(:)))/min(abs(y(:))) > MAX_CALIB_ERR,
        error('Calibration is too inaccurate: something is wrong');
    end
    
    x = signalVal(:, i);
    signalVal(:,i) = polyval(p, x, [], mu);    
end

data = nan(size(signalVal,1), numel(muxData));

for i = 1:size(data,1)
    data(i, :) = interp1(...
        round(linspace(1, size(data,2), size(signalVal,2))), ...
        signalVal(i,:), 1:size(data,2), 'linear');
end


end