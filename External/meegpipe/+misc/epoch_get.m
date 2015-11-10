function [data, ev_out, idx, origPos] = epoch_get(x, ev, varargin)
% epoch_get - Extracts epochs from a data matrix
%
%   DATA = epoch_get(DATA, EV), where DATA is of numeric type and EV is an
%   array of event objects, returns either a cell array or a numeric array
%   with the data epochs corresponding to the given events.
%
%   DATA = epoch_get(OBJ, EV, 'Duration', DUR, 'Offset', OFFSET) extracts
%   epochs identified by the position of the given events but with the
%   provided duration (DUR) and offset (OFFSET).
%
%   DATA = epoch_get(OBJ, POS, 'Duration', DUR, 'Offset', OFFSET) where POS
%   is a numeric array with the locations of the epochs.
%
%   [DATA, EV_OUT] = epoch_get(OBJ, EV) where EV_OUT is the array of
%   events that were used to extract the data in matrix/cell DATA. EV_OUT
%   might be different to EV if some of the events in EV are out of the
%   range of the input data.
%
% See also: PSET/pset, PSET/event, misc/epoch_set


% YOU NEED TO CLEAN UP THIS MESS!!

import misc.process_varargin;
import misc.isevent;

THIS_OPTIONS = {'duration', 'offset', 'dims', 'baselinecorrection'};

if nargin < 1 || isempty(x) || ~isnumeric(x),
    error('misc:epoch_get:invalidInput', ...
        'First input argument must be a non-empty numeric array or pset object.');
end

if mod(nargin, 2),
    error('misc:epoch_get:invalidInput', ...
        'An even number of input arguments is expected.');
end

if nargin < 2 || length(ev)<1,
    if isa(x, 'pset.mmappset'),
        data = x(:,:);
    else
        data    = x;
    end
    ev_out  = ev;
    idx     = 1:size(x,2);
    return;
end

% Default optional parameters
duration            = [];
offset              = 0;
dims                = [];
baselinecorrection  = false;

% Process optional input arguments
eval(process_varargin(THIS_OPTIONS, varargin));

% Positions of the epochs fiducial points
if isevent(ev),
    pos = get(ev, 'Sample');
    if iscell(pos),
        pos = cell2mat(pos);
    end
    if isempty(pos) && isa(x, 'pset.physioset') && ~isempty(x.Event),
        pos = select(x.Event, 'Type', get(ev, 'Type')); 
    end
    offset = get(ev, 'Offset');
elseif isnumeric(ev),
    pos = ev;
else
    error('Something is wrong...');
end

n_pos = numel(pos);

% Durations of the epochs
if isempty(duration),
    if isevent(ev),
        dur = get(ev, 'Duration');
        if iscell(dur),
            dur = cell2mat(dur);
        end
    else
        error('misc:epoch_get:missingDuration', ...
            'The duration of the epochs must be provided.');
    end
else
    dur = repmat(duration, numel(ev), 1);
end

% Offset of the epochs
if isempty(offset),
    if isevent(ev),
        off = get(ev, 'Offset');
        if iscell(off),
            off = cell2mat(off);
        end
    else
        warning('misc:epoch_get:missingOffset', ...
            'Zero offset will be assumed for all epochs.');
        off = zeros(n_pos, 1);
    end
else
    off = repmat(offset, numel(ev),1);
end

% Check if epochs have different channel selections
diffdims = false;
if ~isempty(dims),
    if iscell(dims),
        n_dim = numel(dims{1});
        for j = 2:numel(dims)
            if numel(dims{j}) ~= n_dim || ~all(dims{j}==dims{j-1}),
                diffdims = true;
                break;
            end
        end
        
    end
else
    dims = 1:size(x,1);
end

if ~diffdims && iscell(dims),
    dims = dims{1};
end

if ~diffdims,
    dims = sort(dims(:), 'ascend');
end

% Extract the epochs
udur = unique(dur);
uoff = unique(off);

% Indices of the picked samples
idx = [];

newPos = pos; % position of the events after epoching
%count = 0;    % sample counter
ev_out = ev;
if length(uoff) > 1 || length(udur) > 1 || iscell(dims),
    
    error('Epochs with different offsets/durations/dimensionality are not supported yet!');
else
   
    % Remove epochs out of range
    outofrange = (pos + uoff) < 1 | (pos+uoff+udur-1) > size(x,2);
    pos(outofrange) = [];
    n_pos = length(pos);
    tf = true(1, n_pos);
    if n_pos > 0,
        idx = repmat(pos(:),1,udur) + repmat(uoff:(uoff+udur-1), n_pos, 1);
        idx = idx';
        
        data = reshape(x(dims, idx(:)), numel(dims), udur, n_pos);  
       
        [tf, loc]= ismember(pos, idx);
        
        % Remove events that do not fall in an epoch
        %ev_out(~tf) = [];
        
        % Modify event timing
        newPos = loc;
        %newPos = 1-uoff:udur:n_pos*udur;
        
        if baselinecorrection && uoff < 0,
            idx_baseline  = repmat(pos, 1, abs(uoff)) +  repmat(uoff:-1, n_pos, 1);
            idx_baseline  = idx_baseline';
            data_baseline = reshape(x(dims, idx_baseline(:)), numel(dims), abs(uoff), n_pos);
            data_baseline = repmat(mean(data_baseline,2), [1 udur 1]);
            data = data - data_baseline;
        end
    else
        data = [];
    end
end

if isevent(ev),
    ev_out = ev_out(tf);
    origPos = ev_out;
    for i = 1:numel(ev_out),
        ev_out(i) = set(ev_out(i), 'Sample', newPos(i));
    end
else
    %ev_out = ev(~outofrange);
    ev_out = newPos;
    origPos = ev;
end

origPos = sort(origPos);
ev_out = sort(ev_out);


end
