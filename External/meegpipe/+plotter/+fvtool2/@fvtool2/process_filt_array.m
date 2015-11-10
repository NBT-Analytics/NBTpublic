function varargin = process_filt_array(varargin)
import plotter.fvtool2.*;

if nargin > 1,
    for i = 1:numel(varargin)
        tmp = fvtool2.process_filt_array(varargin{i});
        varargin{i} = tmp{1};
    end
    return;
elseif ~iscell(varargin{1}),
    return;
end

filter = varargin{1};
for j = 1:numel(filter),
    % Process recursively
    if iscell(filter{j}),
        tmp = fvtool2.process_filt_array(filter{j});
        filter{j} = tmp{1};
    end
end

if ndims(filter) ~= 2 || ...
        ~(size(filter,1) == 1 || size(filter,2) == 1),
    msg = ['A cell array with ndims = 2 and at least one ' ...
        'singleton dimension was expected'];
    throw(fvtool2.InvalidFilterArray(msg));
end
if size(filter, 1) > 1,
    % various filters in parallel
    varargin{1} = parallel(filter{:});
elseif size(filter, 2) > 1,
    % various filters as a cascade
    varargin{1} = cascade(filter{:});
elseif numel(filter) == 1
    varargin = filter{1};
else
    error('This should not happen!');
end


end