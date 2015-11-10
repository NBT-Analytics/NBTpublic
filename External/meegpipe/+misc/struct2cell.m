function y = struct2cell(x)

if isempty(x), y = {}; return; end

fNames = fieldnames(x);
y = cell(1, numel(fNames)*2);
count = 1;
for i = 1:numel(fNames)
    y{count} = fNames{i};
    y{count + 1} = x.(fNames{i});
    count = count + 2;
end


end