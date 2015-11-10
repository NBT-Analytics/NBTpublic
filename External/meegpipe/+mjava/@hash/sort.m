function sortedKeys = sort(obj, fh)


hashKeys = keys(obj);
hashVals = values(obj);

sortKey  = cellfun(@(x) fh(x), hashVals);

[~, idx] = sort(sortKey);

sortedKeys = hashKeys(idx);

end