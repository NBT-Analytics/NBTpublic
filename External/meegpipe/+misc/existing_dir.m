function selDir = existing_dir(dirList)

selDir = '';
if iscell(dirList),
    dirExists = cellfun(@(x) exist(x, 'dir')>0, dirList);
    dirList = dirList(dirExists);
    if ~isempty(dirList),
        selDir = dirList{1};
    end
end


end