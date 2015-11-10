function str = event2str(ev)

import misc.any2str;

str = sprintf('Type,%s,Sample,%d,Time,%s,Value,%d,Offset,%d,Duration,%d', ...
    get(ev, 'Type'), get(ev, 'Sample'), datestr(get(ev, 'Time')), ...
    get(ev, 'Value'), get(ev, 'Offset'), get(ev, 'Duration'));

meta = get_meta(ev);

metaNames = fieldnames(meta);

if isempty(metaNames), return; end

for i = 1:numel(metaNames)
   str = [str ...
       sprintf(',%s,%s', metaNames{i}, any2str(meta.(metaNames{i})))]; %#ok<AGROW>
end



end