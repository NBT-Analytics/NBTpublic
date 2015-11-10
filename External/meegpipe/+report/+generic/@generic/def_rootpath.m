function rPath = def_rootpath(obj, varargin)
% DEF_ROOTPATH - Default root directory
%
% rPath = def_rootpath(obj)
%
% Where
%
% RPATH is the absolute path to the report root directory
% 
% See also: get_rootpath, set_rootpath, generic

% Description: Default root directory
% Documentation: class_generic.txt

import pset.session;
import mperl.cwd.abs_path;
import datahash.DataHash;


if isempty(get_parent(obj)),
    dirName = DataHash(randn(1,100));
    
    session.subsession(dirName(end-4:end));
    rPath = abs_path(session.instance.Folder);
    session.clear_subsession;
    
else

    % same dir as the parent
    rPath = fileparts(get_abs_parent(obj));    
    
end


end