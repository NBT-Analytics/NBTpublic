function newVal = clone(val)
% CLONE - Perform as deep copy as possible
%

if isa(val, 'goo.clonable'),
    newVal = clone(val);
elseif iscell(val),
    newVal = cell(size(val));
    for j = 1:numel(val),
        newVal{j} = goo.clone(val{j});
    end
elseif isa(val, 'matlab.mixin.Copyable'),
    % Shallow copy better than nothing
    % This is convenient but unsafe...
    newVal = copy(val);
elseif isa(val, 'handle'),
    error('Cannot perform deep copy!');
else
    newVal = val;
end


end