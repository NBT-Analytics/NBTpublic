function dirName = get_full_dir(obj, data)
% GET_FULL_DIR - Full path to root dir where the node stores outputs
%
% dirName = get_full_dir(obj, data)
%
% Where
%
% DATA is the data at the input of the node. Note that DATA needs not be
% provided once the node has been initialized.
%
% DIRNAME is the full path to the directory where the processing results
% will be stored.
%
%
% See also: get_dir


import misc.get_username;
import misc.get_matlabver;
import mperl.file.spec.catdir;
import meegpipe.node.abstract_node;
import mperl.file.spec.rel2abs;

if initialized(obj),
    dirName = obj.RootDir_;
    return;
end

if nargin < 2 || isempty(data),
    data = [];
end

if isempty(get_parent(obj)),
    % Top-level node   
    
    dataDir = get_data_dir(obj, data);
    
    subDirName = sprintf('%s_%s_%s', ...
        [get_name(obj) '-' get_id(obj)], ... 
        get_username, ...
        [computer '-' get_matlabver]);
    
    dirName = catdir(dataDir, subDirName);    
    
else
    % A child node (a node within a pipeline)
    
    parentDir = get_full_dir(get_parent(obj), data);
    dirName   = catdir(parentDir, get_name(obj));    
    
end  


end