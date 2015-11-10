function [mergedData, data] = process(obj, fileList, varargin)


import mperl.file.spec.catfile;
import goo.globals;
import misc.eta;

if ischar(fileList),
    fileList = {fileList};
end

if ~iscell(fileList) || ~all(cellfun(@(x) ischar(x), fileList)),
    error('File list must be a cell array of strings');
end

importer  = get_config(obj, 'Importer');

verboseLabel     = get_verbose_label(obj);
origVerboseLabel = globals.get.VerboseLabel;
globals.set('VerboseLabel', verboseLabel);

data = cell(1, numel(fileList));

if numel(importer) == 1 && numel(fileList) > 1,
    importer = repmat(importer, 1, numel(fileList));
end


for i = 1:numel(fileList)
    
    [~, name] = fileparts(fileList{i});
    tempDataFile = catfile(get_tempdir(obj), name);
    importer{i}.FileName = tempDataFile;
    data{i} = import(importer{i}, fileList{i});
    
    if has_selection(data{i}),
        warning('merge:UnsupportedDataSelections', ...
            'Dataset %s contains selections: removing them', ...
            get_name(data{i}));
        clear_selection(data{i});
    end
    
end

mergedData = merge(data{:}, 'DataFile', fileList{1}, ...
    'Path', get_full_dir(obj, fileList{1}));

%% Undo stuff
globals.set('VerboseLabel', origVerboseLabel);


end