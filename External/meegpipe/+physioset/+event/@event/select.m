function [ev_out, idx] = select(ev, varargin)
% SELECT - Selects events that fulfil some criteria
%
% newEvArray = select(evArray, 'propName', value, 'propName2', value2, ...)
%
% Where
%
% EVARRAY is an array of pset.event objects
%
% NEWEVARRAY is an array that contains only those entries in EVARRAY whose
% properties have the especified values. 
% 
%
% See also: pset.event

import physioset.event.event;
import misc.process_varargin;
import misc.struct2cell;

if nargin < 2,
    ev_out = ev;
    return;
end

if nargin == 2 && isstruct(varargin{1}),
    varargin = struct2cell(varargin{1});
end

% Select the events
selection = false(size(ev));
i = 1;
while i < numel(varargin)
    value = varargin{i+1};
    if isempty(value), continue; end    
    if isnumeric(value) && length(value) < 2,
        for j = 1:numel(ev)
            query = get(ev(j), varargin{i});
            if ~isempty(query) && ~any(isnan(query) | query ~= value),
                selection(j) = true;
            end       
        end
    elseif isnumeric(value) && numel(value) == 2 && size(value,1) == 1
        for j = 1:numel(ev)
            query = get(ev(j), varargin{i});
            if ~isempty(query) && ~any(isnan(query) | ...
                    query > value(2) | query < value(1)),
                selection(j) = true;
            end            
        end
    elseif isnumeric(value),
        for j = 1:numel(ev)
            query = get(ev(j), varargin{i});
            if ~isempty(query) && ~any(isnan(query)) || ...
                    ~all(ismember(query, value)),
                selection(j) = true;
            end            
        end
    elseif ischar(value)
        for j = 1:numel(ev)
            query = get(ev(j), varargin{i});
            if ~isempty(query) && ~any(isnan(query) | ...
                    ~strcmpi(query, value)),
                selection(j) = true;
            end            
        end
    elseif iscell(value) && ~isempty(value) && ischar(value{1})
        for j = 1:numel(ev)
            query = get(ev(j), varargin{i});
            if ~isempty(query) && ~any(isnan(query) | ...
                    ~ismember(query, value)),
                selection(j) = true;
            end            
        end
    elseif iscell(value) && ~isempty(value) && isnumeric(value{1}),
        for j = 1:numel(ev)
            query = get(ev(j), varargin{i});
            if ~isempty(query) && ~any(isnan(query) | ...
                    ~ismember(query, cell2mat(value))),
                selection(j) = true;
            end            
        end
    end
    i = i + 2;
end
idx = find(selection);
ev_out = ev(selection);