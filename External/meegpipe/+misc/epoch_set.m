function x = epoch_set(x, ev, e_data, varargin)
% epoch_set - Sets epochs from a data matrix
%   
%   DATA = epoch_set(DATA, EV, E_DATA), where DATA is the numeric dataset,
%   EV is an array of event objects identifying the location of the epochs,
%   and E_DATA is the data that will be placed at the location of the
%   epochs. E_DATA can be either a numeric matrix (if epochs have the same
%   length and the same dimensionality) or a cell array.
%
%   DATA = epoch_set(DATA, POS, 'Offset', OFF) where POS is a numeric array
%   with the locations of the epochs and OFF is the relative offset of the
%   first sample in an epoch.
%
% See also: PSET/pset, PSET/event, misc/epoch_get


import misc.process_varargin;
import misc.isevent;

THIS_OPTIONS = {'offset', 'dims', 'indices'};

if nargin < 3 || isempty(ev) || ~mod(nargin, 2),
    error('misc:get_epoch:invalidInput', ...
        'An odd number of input arguments is expected.');
end

% Default optional parameters
offset  = [];
dims    = [];
indices = [];

% Process optional input arguments
eval(process_varargin(THIS_OPTIONS, varargin));

% Positions of the epochs fiducial points
n_ev = numel(ev);
if isevent(ev),
    pos = nan(n_ev,1);
    for i = 1:n_ev
        pos(i) = ev(i).Sample;
    end
elseif isnumeric(ev),
    pos = ev;
end

n_ev = numel(pos);

% Time indices of the epochs
if isempty(indices),
    if iscell(e_data),        
        % Epochs might have different duration
        indices = cell(n_ev,1);
        for i = 1:n_ev
            indices{i} = 1:size(e_data{i},2);            
        end
    else
        indices = 1:size(e_data,2);        
    end
end

if isempty(offset),
    if isevent(ev),
        off = nan(n_ev, 1);
        for i = 1:n_ev
            off(i) = ev(i).Offset;             
        end        
    else
        % Assume zero offset
        warning('misc:get_epoch:missingOffset', ...
            'Zero offset will be assumed for all epochs.');  
        off = zeros(n_ev, 1);
    end
else
    off = repmat(offset, n_ev, 1);
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
    %dims = sort(dims(:), 'ascend');
    if min(dims) < 1 || max(dims) > size(x,1) || length(dims) > size(e_data,1),
        error('misc:set_epoch:invalidDims', 'Invalid selection of dimensions.');
    end
end

% Set the epoch values
uoff = unique(off);
if length(uoff) > 1 || iscell(indices) || iscell(dims),
    if iscell(indices),
        if iscell(dims),
            % Both indices and dims are cells            
            for i = 1:n_ev
                if (pos(i) + off(i) > 1) && ...
                        (pos(i) + off(i) + max(indices{i}) - 1) < size(x,2) && ...
                         max(dims{i}) < size(x,1) && min(dims{i})>0,                   
                   x(dims{i}, pos(i) + off(i) + indices{i}-1) = e_data(:,:,i);
                end
            end
        else
            % Only indices are cells           
            for i = 1:n_ev
                if (pos(i) + off(i) > 1) && (pos(i) + off(i) + max(indices{i}) - 1) < size(x,2),
                  x(dims, pos(i) + off(i) + indices{i}-1) = e_data(:,:,i);
                end                
            end
        end        
    else        
        if iscell(dims),
            % Only dims are cells           
            i_max = max(indices);
            for i = 1:n_ev
                if (pos(i) + off(i) > 1) && (pos(i) + off(i) + i_max - 1) < size(x,2),
                  x(dims{i}, pos(i) + off(i) + indices-1) = e_data(:,:,i);
                end
                
            end
        else
            % Neither dims nor indices are cells but offsets are differents            
            i_max = max(indices);
            for i = 1:n_ev
                if (pos(i) + off(i) > 1) && (pos(i) + off(i) + i_max - 1) < size(x,2),
                   x(dims, pos(i) + off(i) + indices - 1) = e_data(:,:,i);
                end                
            end
        end
        
    end
    
else
    % Remove epochs out of range
    outofrange = (pos + uoff)<1 | (pos+uoff+max(indices)-1) > size(x,2);
    pos(outofrange) = [];
    n_ev = length(pos);
    idx = repmat(pos-1, 1, length(indices)) + repmat(uoff+indices, n_ev, 1);
    idx = idx';
    x(dims, idx) = reshape(e_data, size(e_data,1), size(e_data,2)*size(e_data,3));
end

