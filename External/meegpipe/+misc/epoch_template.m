function [y, ev_out] = epoch_template(eeg, ev, varargin)
% epoch_template - Builds an epoch template using labeled data
%
%   DATA = epoch_template(DATA, EV), where DATA is of numeric type and EV
%   is an array of event objects, returns a numeric array with a template
%   for the selected epochs.
%
%   DATA = epoch_template(OBJ, EV, 'Duration', DUR, 'Offset', OFFSET) 
%   extracts epochs identified by the position of the given events but with
%   the provided duration (DUR) and offset (OFFSET). 
%
%   DATA = get_epoch(OBJ, POS, 'Duration', DUR, 'Offset', OFFSET) where POS
%   is a numeric array with the locations of the epochs.
%
%   [DATA, EV_OUT] = get_epoch(OBJ, EV) where EV_OUT is an array containing
%   the events that were used to build matrix/cell DATA. EV_OUT will be
%   different from EV, if some of the events in EV are out of the range of
%   the input data.
%
% See also: misc/epoch_align

import misc.ispset;
import misc.isevent;
import misc.epoch_get;
import misc.epoch_align;
import misc.center;

if nargin < 1 || isempty(eeg) || ~isnumeric(eeg),
    error('misc:epoch_template:invalidInput', ...
        'First input argument must be a non-empty numeric array or pset object.');
end

if mod(nargin, 2),
    error('misc:epoch_template:invalidInput', ...
        'An even number of input arguments is expected.');
end

if nargin < 2 || isempty(ev),
    y = [];
    return;
end

% Extract the epochs corresp. to the selected events
[data, ev_out] = epoch_get(eeg, ev, varargin{:});

% Center and align the epochs
data = center(data);
data = epoch_align(data);

y = nanmean(data,3);


     




