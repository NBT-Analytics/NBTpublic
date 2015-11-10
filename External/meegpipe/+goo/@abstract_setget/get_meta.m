function value = get_meta(obj, varargin)
% GET_META - Get meta property value
%
% See also: goo.set_meta

if isempty(obj), value = []; return; end

if numel(obj) > 1,
    % extremely inefficient and not too robust, but easy..
    value = get_meta(obj(1), varargin{:});
    if numel(varargin) == 1,
        value = {value};
    end
    value = repmat(value, size(obj));
    for i = 2:numel(obj)
        tmp = get_meta(obj(i), varargin{:});
        if numel(varargin) == 1,
            value(i) = {tmp};
        else
            value(i) = tmp;
        end
    end
    return;
end

if nargin < 2, value = obj.Info; return; end

if numel(varargin) < 2,
    if isfield(obj.Info, varargin{1}),
        value = obj.Info.(varargin{1});
    else
        value = [];
    end
    return;
end

metaNames = fieldnames(obj(1).Info);
[args, idx] = intersect(varargin, metaNames);

value = repmat({[]}, 1, numel(varargin));

for i = 1:numel(args)
    value{idx(i)} = obj.Info.(args{i});
end


end