function value = get_meta(obj, varargin)
% GET_META - Get meta property value
%
% See also: goo.set_meta

if nargin < 2, value = obj.Info; return; end

if numel(varargin) < 3,
    if isfield(obj.Info, varargin{1}),
        value = obj.Info.(varargin{1});
    else
        value = [];
    end
    return;
end

metaNames = fieldnames(obj.Info);
[args, idx] = intersect(varargin, metaNames);

value = repmat({[]}, 1, numel(varargin));

for i = 1:numel(args)
    value{idx(i)} = obj.(args{i});
end


end