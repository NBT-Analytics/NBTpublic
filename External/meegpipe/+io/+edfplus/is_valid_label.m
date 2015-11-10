function out = is_valid_label(label, type)
% IS_VALID_LABEL - Tests whether a sensor label is valid
%
% bool = is_valid_label(label)
%
% bool = is_valid_label(label, type)
%
% 
% Where
%
% LABEL is a sensor/signal label. LABEL can also be a cell array of signal
% labels.
%
% BOOL is true only if the provided label is a valid EDF+ sensor label.
% Otherwise, BOOL is false
%
% If TYPE is provided, then the label must be valid and of the provided
% type for BOOL to be true. TYPE can also be a cell array of types.
%
%
% See also: is_valid_dim, signal_types

% Documentation: pkg_io_edfplus.txt
% Description: Tests validity of a sensor label


import io.edfplus.signal_types; 
import io.edfplus.is_valid_label;

%% Ensure input arguments are cell arrays of strings
if nargin < 2, type = []; end    

if nargin < 1, 
    error('At least one input argument is expected');
end

if ~iscell(label),
    label = {label};
end

if iscell(type) && numel(type) ~= numel(label),
    error(['Number of provided signal labels does not match the ' ...
        'number of provided signal types']);
end
if iscell(type) && numel(type) == 1,
    type = repmat(type, numel(label), 1);
elseif ischar(type)
    type = repmat({type}, numel(label), 1);
elseif ~isempty(type),
    error('Invalid data type for argument TYPE');
end

%% Check if the signal label is valid at all


signalTypes = cellfun(@(x) get_type(x), label, 'UniformOutput', false);

signalTypes = signal_types(signalTypes);

out = cellfun(@(x) ~isempty(x), signalTypes);

%% Does the type derived from the label match the expected signal type?
if ~isempty(type),
    out = out & strcmpi(signalTypes, type(:)); 
end

end

%% Get signal type from label
function type = get_type(label)

match = regexp(label, '^(?<type>\w+)\s+[^\s]+$', 'names');
if iscell(match), match = match{1}; end
if isempty(match),
    match = regexpi(label, '^(?<type>\w+)$', 'names');
    if iscell(match), 
        match = match{1}; 
    elseif isempty(match),
        type = '';
        return;
    end
end
type = match.type;

end

