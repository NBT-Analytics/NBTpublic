function y = filter(obj, x, d, varargin)

import misc.eta;

verbose = is_verbose(obj);
verboseLabel = get_verbose_label(obj);

origVerb = goo.globals.get.Verbose;
goo.globals.set('Verbose', false);

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
for i = 1:numel(winOnset)
    
    winTimeRange = winOnset(i):winOnset(i)+winLength-1;
    
    for j = 1:size(x,1),
        thisY = filter(obj.Filter, x(j, winTimeRange), d(:, winTimeRange));
        
        y(j, winTimeRange(winTimeRange > lastSample)) = 0;
        
        y(j, winTimeRange) = y(j, winTimeRange) + thisY.*win;
    end
    
    lastSample = winTimeRange(end);
    
    unitVec(winTimeRange) = unitVec(winTimeRange) + win;
    
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

goo.globals.set('Verbose', origVerb);

end