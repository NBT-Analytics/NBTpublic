function y = cell2ticks(x)

x = flipud(x);
nCols = 1;
for i = 1:numel(x),
    nCols = max(nCols, numel(x{i}));
end
y = repmat(' ', numel(x), nCols);
for i = 1:numel(x)
   y(i, end-numel(x{i})+1:end) = x{i}; 
end




end