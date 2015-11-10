function y = split(sep, str)

idx = strfind(str, sep);

if isempty(idx),
    y = [];
    return;
end

y = cell(numel(idx)+1,1);
first = 1;
for i = 1:numel(idx)
   last = idx(i)-1;
   y{i} = str(first:last);
   first = last+2;
end
y{i+1} = str(first:end);
if isempty(y{end}), y = y(1:end-1); end


end