function obj = set(obj, varargin)

import misc.struct2cell;
import misc.any2str;

if nargin == 2 && iscell(varargin{1}),
    varargin = varargin{1};
elseif nargin == 2 && isstruct(varargin{1}),
    varargin = struct2cell(varargin{1});
end

if numel(varargin) > 1 && islogical(varargin{1}),
    % For backwards compatiblity
    varargin = varargin(2:end);

end

% Take care of first object
for i = 1:2:numel(varargin)
    if numel(varargin) < i+1,
        error('No value provided for argument #1: %s', i, ...
            any2str(varargin{i}, 20));        
    end
    thisValue = varargin{i+1};
    obj.(varargin{i}) = thisValue;
end

if numel(obj) < 2, return; end;


% An array of objects
for i = 1:2:numel(varargin)    
    for j = 1:numel(obj)
        if ischar(varargin{i+1}) || numel(varargin{i+1}) < 2,
            thisValue = varargin{i+1};
        elseif iscell(varargin{i+1})
            thisValue = varargin{i+1}{j};
        else
            thisValue = varargin{i+1}(j);
        end
        obj(j).(varargin{i}) = thisValue;
    end    
end


end