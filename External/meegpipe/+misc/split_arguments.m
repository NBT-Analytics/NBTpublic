function [args1, args2] = split_arguments(props, varargin)
% split_arguments - Split varargin into two non-overlapping sets
%
% See also: misc.process_arguments

if numel(varargin) == 1 && iscell(varargin{1}),
    varargin = varargin{1};
end

% Other stuff can come before the first key
count = 0;
while (count < numel(varargin) && ~ischar(varargin{count+1})),
    count = count + 1;
end

otherStuff = varargin(1:count);
varargin   = varargin(count+1:end);

if isstruct(props), props = fieldnames(props); end

if ischar(props), props = {props}; end

if isempty(props),
   args1 = {};
   args2 = varargin;
   return;
end


propNameIdx = 1:2:numel(varargin);
isSelected = cellfun(@(x) ismember(x, lower(props)), lower(varargin(propNameIdx)));

selIdx = propNameIdx(isSelected);
selIdx = sort([selIdx selIdx + 1], 'ascend');

noselIdx = setdiff(1:numel(varargin), selIdx);

args1 = varargin(selIdx);
args2 = [otherStuff, varargin(noselIdx)];



end