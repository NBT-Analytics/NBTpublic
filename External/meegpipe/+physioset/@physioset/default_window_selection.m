function windows = default_window_selection(data, maxWin, winLength)

if maxWin < 1 || winLength < 1/data.SamplingRate,
    windows = [];
    return;
end

winLength = min(max(1, round(winLength*data.SamplingRate)), size(data,2));

if maxWin == 1 || winLength == 1,
    windows = [1 size(data,2)];
    return;
end

winEnd   = winLength:winLength:size(data,2);
winStart = winEnd - winLength + 1;
nbWins   = numel(winStart);

badSamples = reshape(data.BadSample(1:nbWins*winLength), winLength, ...
    nbWins);

% Remove bad windows
isBad           = any(badSamples);
winStart(isBad) = [];
winEnd(isBad)   = [];

if isempty(winStart),
    winStart = 1;
    winEnd   = size(data,2);
    windows = [winStart winEnd];
    return;
end

if isempty(winStart),
    error('Could not find any clean data window');
else
    idx         = randperm(numel(winStart));    
    maxWin      = min(maxWin, numel(winStart));
    idx         = idx(1:maxWin);
    idx         = sort(idx, 'ascend');
    winStart    = winStart(idx);
    winEnd      = winEnd(idx);
end

windows = [winStart(:) winEnd(:)];

end