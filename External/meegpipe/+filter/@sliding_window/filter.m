function y = filter(obj, x, varargin)

import misc.eta;

verbose = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

origVerboseLabel = goo.globals.get.VerboseLabel;
goo.globals.set('VerboseLabel', verboseLabel);

if isa(obj.WindowLength, 'function_handle')
    winLength = obj.WindowLength(x.SamplingRate);
else
    winLength = obj.WindowLength;
end

winShift = round(winLength*(1-obj.WindowOverlap/100));
winOnset = 1:winShift:size(x,2);

winOnset(winOnset + winLength - 1 > size(x,2)) = [];

win = window(obj.WindowFunction, winLength);
win = reshape(win, 1, numel(win));
win = repmat(win, size(x, 1), 1);

if isa(x, 'pset.mmappset'),
    y = copy(x);
else
    y = nan(size(x));
end

lastSample = 0;

unitVec = zeros(1, size(x,2));

if verbose,
    fprintf([verboseLabel ...
        'Filtering with %s in %d windows (L=%d, overlap=%d%%) ...'], ...
        get_name(obj.Filter), numel(winOnset), winLength, ...
        round(obj.WindowOverlap));
end
tinit = tic;
myFilt = set_verbose(obj.Filter, false);

if isa(x, 'physioset.physioset'),
    sr = x.SamplingRate;
else
    sr = [];
end

for i = 1:numel(winOnset)
    
    winTimeRange = winOnset(i):winOnset(i)+winLength-1;
    
    if nargin > 2, 
        % To make it work with regression filters as well
        thisY = filter(myFilt, x(:, winTimeRange), ...
            varargin{1}(:, winTimeRange), 'SamplingRate', sr);
    else
        thisY = filter(myFilt, x(:, winTimeRange), 'SamplingRate', sr);
    end
    
    y(:, winTimeRange(winTimeRange > lastSample)) = 0;

    y(:, winTimeRange) = y(:, winTimeRange) + thisY.*win;
  
    lastSample = winTimeRange(end);
    
    unitVec(winTimeRange) = unitVec(winTimeRange) + win(1,:);
    
    if verbose,
        eta(tinit, numel(winOnset), i);
    end
end
if verbose, fprintf('\n\n'); end

if verbose,
    fprintf([verboseLabel 'Fixing the scale of the filtered signals ...']);
end
y = y./max(unitVec);
if verbose, fprintf('[done]\n\n'); end

if isa(x, 'pset.mmappset'),
    y = assign_values(x, y);
end

goo.globals.set('VerboseLabel', origVerboseLabel);

end