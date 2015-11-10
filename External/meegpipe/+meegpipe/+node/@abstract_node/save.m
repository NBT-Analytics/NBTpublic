function data = save(obj, data, varargin)
% SAVE - Saves node output to a disk file
%
% save(obj, data, dataIn)
%
% Where
%
% DATA is the output physioset object, i.e. the physioset that contains the
% data to be saved.
%
% DATAIN is the input physioset object. This is necessary for figuring the
% name of the output disk file.
%
% See also: node,abstract_node


import exceptions.*;


if iscell(data),
    for i = 1:numel(data)
        save(data{i});
    end
else
    outputFileName = get_output_filename(obj, data);
   
    [~, name, ext] = fileparts(outputFileName);
    
    savePath = get_full_dir(obj);
    
    if isempty(get_parent(obj))
        % This is a top-level pipeline
        set_name(data, name);
    end
    
    move(data, ...
        'Path',     savePath, ...
        'DataFile', [name ext], ...
        'PostFix',  '', ...
        'PreFix',   '');
   
    save(data);

end

end