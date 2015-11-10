function obj = set_verbose_label(obj, verboseValue)

obj = set_verbose_label@filter.abstract_dfilt(obj, ...
    verboseValue);
for i = 1:numel(obj.LpFilter)
    if isempty(obj.LpFilter{i}), continue; end
    obj.LpFilter{i} = ...
        set_verbose_label(obj.LpFilter{i}, verboseValue);
end
for i = 1:numel(obj.HpFilter)
    if isempty(obj.HpFilter{i}), continue; end
    obj.HpFilter{i} = ...
        set_verbose_label(obj.HpFilter{i}, verboseValue);
end
end