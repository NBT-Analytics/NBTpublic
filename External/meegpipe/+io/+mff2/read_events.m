function evArray = read_events(filename, fs, beginTime, epochs)

import mperl.split;
import misc.isinteger;
import io.mff2.read_header;
import io.mff2.read_data;
import io.mff2.parse_begin_time;

if nargin < 4 || isempty(epochs),
    warning('mff2:MissingEpochInfo', ...
        ['Epoch information was not provided: event info cannot be ' ...
        'accurately retrieved so events will be ignored']);
    evArray = [];
    return;
end

if nargin < 3 || isempty(beginTime),
    hdr = read_header(filename);
    beginTime = hdr.beginTime;
end
% As a datenum
beginTime = parse_begin_time(beginTime);

if nargin < 2 || isempty(fs),
    error('The sampling rate needs to be provided!');
end

% Important: keep the '/' at the end. For some reason it is required
% under Linux (otherwise Perl's find() does not realize that the .mff
% file is a directory).
res = perl('+io/+mff2/private/parse_events.pl', [filename '/']);
res = split(char(13), res);

nbEvents = numel(res);

if ~isinteger(nbEvents),
    error('Something went wrong');
end

evArray = repmat(physioset.event.event, nbEvents, 1);
evCount = 0;

% Epochs begin and end times (in ns)
epochBeginTime = cell2mat({epochs(:).begin_time});
epochEndTime = cell2mat({epochs(:).end_time});

% Transform to seconds
epochBeginTime = epochBeginTime*1e-6;
epochEndTime   = epochEndTime*1e-6;

% Duration of each epoch in samples
epochDurSamples = round((epochEndTime - epochBeginTime)*fs);
epochFirstSample = [1 cumsum(epochDurSamples(1:end-1))+1];

for evItr = 1:nbEvents
    
    this        = split(char(10), res{evItr});    
    evTime      = this{1};
    duration    = this{2};
    code        = this{3};
    
    % Custom event properties
    this(1:3) = [];
    for i = 1:2:numel(this)
        this{i} = regexprep(this{i}, '[^\w]', '');
        evArray(evItr) = set_meta(evArray(evItr), this{i}, ...
            str2double(this{i+1}));
    end   
    
    if isempty(beginTime),
        continue;
    end
    
    % As a datenum
    evTime   =  parse_begin_time(evTime);
    
    % Time from the beginning of the recording in seconds
    % This is the same (and must faster) than calling datevec and etime
    evTimeDiff = (evTime - beginTime)*24*60*60;
    
    % Find the beginning time of the corresponding epoch
    epochIdx = find(epochBeginTime <= evTimeDiff & ...
        evTimeDiff <= epochEndTime);
    thisEpochBeginTime = epochBeginTime(epochIdx);
    if isempty(thisEpochBeginTime),
        warning('read_events:OutofRangeEvent', ...
            'Event time location out of range');
    end

    % Location of the event within the epoch (in samples)
    evSample = (evTimeDiff-thisEpochBeginTime)*fs;
    
    % The event sample relative to the first sample in the recording
    evSample = evSample + epochFirstSample(epochIdx);   

    evCount = evCount + 1;
    % We set only public props so this is faster than using method
    % set(), which is generally preferred. As .mff files can
    % contain thousands of events, this can save some time.
    evArray(evCount).Sample      = ceil(evSample);
    evArray(evCount).Type        = code;
    evArray(evCount).Duration    = ...
        ceil(str2double(duration)./1000000*fs);
    evArray(evCount).Time        = evTime;
    
end

end