function sClass = default_label2class(labelArray, className, classRegex)
% DEFAULT_LABEL2CLASS - Map sensor labels to valid sensor classes
%
%   sClass = default_label2class(labelArray, className, classRegex)
%
% Where
%
% LABELARRAY is a cell array of sensor labels (strings).
%
% CLASSNAME is a cell array of sensor classes (strings).
%
% CLASSREGEX is a cell array of regular expressions matching the various
% sensor classes.
%
% SCLASS is a cell array of class names (strings).
%
% STYPE is a cell array of sensor types (strings), when applicable. For
% instance MEG sensors can be gradiometers (type=grad) or magnetometers
% (type=mag).
%
%
% See also: sensors


if nargin < 3 || isempty(classRegex) || isempty(className),
    % sys = system channels -> do not translate into data channels! so you
    % may have more sensor labels than actual rows in the data matrix
    className = {'eeg', 'meg', 'trigger', 'sys', 'physiology'};
    classRegex = {...
        '(EEG|EOG|E\d|eeg|eog|e\d)\s?', ...
        '(MEG|meg)(\d+)', ...
        '(STI|sti)\d+', ...
        '(SYS|sys)\d+', ...
        '([^\s]+)\s*([^\s]*)' ...
        };
end

verbose = goo.globals.get.Verbose;
verboseLabel = goo.globals.get.VerboseLabel;

isMatched   = false(size(labelArray));
sClass      = cell(size(labelArray));
isAmbiguous = false(size(labelArray));

for classItr = 1:numel(className),
    isThisClass = ...
        cellfun(@(x) ~isempty(x), regexp(labelArray, classRegex{classItr}));
    if classItr < numel(className)
        isAmbiguous = isAmbiguous | (isThisClass & isMatched);
    end
    % The first listed classes take preference
    isThisClass(isMatched) = false;
    nbThisClass = numel(find(isThisClass));
    sClass(isThisClass) = repmat(className(classItr), nbThisClass, 1);
    if verbose && any(isThisClass),
        fprintf([verboseLabel 'Found %d %s sensor(s): %s\n\n'], ...
            nbThisClass, ...
            className{classItr}, ...
            misc.any2str(labelArray(isThisClass)));
    end
    isMatched = isMatched | isThisClass;
end

if any(isAmbiguous),
    warning('label2classes:AmbiguousLabel', ...
        'The following sensor labels are ambiguous: %s\n\n', ...
        misc.any2str(labelArray(isAmbiguous)));
end

if ~all(isMatched)
    warning('label2class:UnknownSensorClass', ...
        'Using default %s class for sensor(s): %s\n\n', className{end}, ...
        misc.any2str(labelArray(~isMatched)));
    sClass(~isMatched) = repmat(className(end), numel(find(~isMatched)), 1);
end

end