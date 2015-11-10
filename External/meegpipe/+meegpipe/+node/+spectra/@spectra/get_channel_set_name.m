function chanSetName = get_channel_set_name(chanSet)

import mperl.join;

if iscell(chanSet),
    chanSet = cellfun(@(x) strrep(strrep(x, '^', ''), '$', ''), chanSet, ...
        'UniformOutput', false);
    if numel(chanSet) == 1,
        chanSet = chanSet{1};
    elseif numel(chanSet) < 3,
        chanSet = join('_', chanSet);
    else
        chanSet = join('', [chanSet(1) {'___'} chanSet(end)]);
    end
end

if isnumeric(chanSet)
    if numel(chanSet) == 1,
        chanSetName = num2str(chanSet);
    elseif numel(chanSet) == 2,
        chanSetName = [num2str(chanSet(1)) '_' num2str(chanSet(2))];
    else
        hashCode = datahash.DataHash(chanSet);
        chanSetName = [num2str(chanSet(1)) '_' hashCode(1:6) ...
            '_' num2str(chanSet(2))];
    end
elseif numel(chanSet) > 2 && strcmp(chanSet(1), '^') && ...
        strcmp(chanSet(end), '$'),
    chanSetName = chanSet(2:end-1);
else
    chanSetName = chanSet;
end

chanSetName = regexprep(chanSetName, '\s+', '');

end