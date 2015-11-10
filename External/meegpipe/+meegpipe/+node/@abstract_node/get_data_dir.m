function dirName = get_data_dir(~, data)
% GET_DATA_DIR - Directory that corresponds to give data
%
% dirName = get_data_dir(obj, data)
%
% Where
%
% DATA is the data object (a built-in type or user-defined object) at the
% input of a processing node.
%
% DIRNAME is the name of the root directory under which node outputs will
% be stored.
%
% See also: node

import misc.var2name;
import pset.session;
import mperl.file.spec.catdir;
import mperl.file.spec.rel2abs;

if ischar(data),
    % data is a filename
    
    [dirName, dataName] = fileparts(data);
    
elseif isa(data, 'goo.abstract_named_object') ||  ...
        isa(data, 'goo.abstract_named_object_handle'),
    % data is a named object
    
    dataName = get_name(data);
    dirName  = fileparts(get_datafile(data));
    
elseif iscell(data) && all(cellfun(@(x) ischar(x), data)) && ...
        exist(data{1}, 'file')
    [dirName, dataName]= fileparts(data{1});
    
else
    
    % input data could be anything else (e.g. an unnamed numeric matrix)
    dirName = session.instance.Folder;
    dataName = var2name(data);
    
end

dirName = rel2abs(catdir(dirName, [dataName '.meegpipe']));


end