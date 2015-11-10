function dirName = get_dir(obj)
% GET_DIR - Node directory
%
% dirName = get_dir(obj)
%
% Where
%
% DIRNAME is the node root directory, i.e. the directory where node
% configuration files and the node report are stored.
%
% See also: node, abstract_node

% Description: Node directory
% Documentation: class_abstract_node.txt

import misc.get_username;
import misc.get_hostname;
import misc.get_matlabver;


if isempty(get_parent(obj)),
    % Parentless node, e.g. a pipeline
    
    dirName = get_name(obj);
    dirName = regexprep(dirName, '[^\w]', '-');
    dirName = sprintf('%s_%s_%s', ...
        dirName, ...
        get_username, ...
        [get_hostname '-' computer '-' get_matlabver]);
    
else
    % A leaf node, e.g. a node within a pipeline
    dirName  = get_name(obj);
    dirName  = regexprep(dirName, '[^\w]+', '-');
    
end

end