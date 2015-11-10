function [chanGroups, chanClasses, chanTypes] = ...
    default_channel_groups(data, maxChans, selChanClasses, selChanTypes)
% DEFAULT_CHANNEL_GROUPS - Default channel grouping for plotting
%
% 
% See also: pset.plotter.space.psd


import mperl.join;
import goo.pkgisa;

if ~pkgisa(data, 'physioset'),
    error('DATA must be a physioset object');
end

if nargin < 4 || isempty(selChanTypes), selChanTypes = ''; end

if nargin < 3 || isempty(selChanClasses), selChanClasses = ''; end

if nargin < 2,
    maxChans = [];
end

% selChanTypes and selChanClasses must be cell arrays
if ~isempty(selChanTypes) && ~iscell(selChanTypes), 
    selChanTypes = {selChanTypes};
end
if ~isempty(selChanClasses) && ~iscell(selChanClasses),
    selChanClasses = {selChanClasses};
end

% Channels classes must be fully specified classes, e.g. sensors.eeg
if ~isempty(selChanClasses),
    selChanClasses = cellfun(@(x) regexprep(x, 'sensors.', ''), ...
        selChanClasses, 'UniformOutput', false);
    selChanClasses = cellfun(@(x) ['sensors.' lower(x)], selChanClasses, ...
        'UniformOutput', false);
end

% Initialize output
chanGroups  = [];
chanClasses = [];
chanTypes   = [];

[cArray, cArrayIdx] = sensor_groups(sensors(data));

for grpItr = 1:numel(cArrayIdx),
    % Discard channels of the wrong class
    if ~isempty(selChanClasses) && ...
            ~ismember(class(cArray{grpItr}), selChanClasses),
        continue;
    end      
    
    % Discard bad channels
    thisChannels = setdiff(cArrayIdx{grpItr}, find(is_bad_channel(data)));
    
    % Discard channels of the wrong type
    if ~isempty(selChanTypes)
        wrongTypeChans = find(~ismember(types(cArrayIdx), selChanTypes));
        thisChannels = setdiff(thisChannels, wrongTypeChans);
    end    
   
    if isempty(maxChans) || numel(thisChannels) < maxChans,
        chanIdx = thisChannels;
    else
        idx     = ceil(linspace(1,numel(thisChannels), maxChans));
        chanIdx = thisChannels(idx);
        chanIdx = unique(chanIdx);
    end
    if ~isempty(chanIdx),
        chanGroups    = [chanGroups;{chanIdx}];  %#ok<*AGROW>
        thisChanClass = class(cArray{grpItr});
        thisChanClass = regexprep(thisChanClass, '^sensors.', '');
        chanClasses   = [chanClasses; {thisChanClass}];
        thisChanTypes = unique(types(cArray{grpItr}));
        thisChanTypes = join(', ', thisChanTypes);
        chanTypes     = [chanTypes; {thisChanTypes}];
    end
end

if numel(chanGroups) == 1,
    chanGroups  = chanGroups{1};
    chanClasses = chanClasses{1};
    chanTypes   = chanTypes{1};
end

