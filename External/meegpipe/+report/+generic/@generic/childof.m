function obj = childof(obj, parent)
% CHILDOF - Define parent report
%
% childof(obj, parent)
%
% Where
%
% PARENT is either a generator object or directly the file name of the
% a remark text file.
%
% See also: get_parent, remark


import mperl.file.spec.abs2rel;
import misc.fid2fname;
import exceptions.*;

if isa(parent, 'report.report'),   
    if ~initialized(parent), initialize(parent); end
    parentRoot = get_rootpath(parent);
    parent     = get_abs_filename(parent);      
elseif ischar(parent) && exist(parent, 'file'), 
    parentRoot = fileparts(parent);  
else
    parent = fid2fname(parent);
    parentRoot = fileparts(parent);
end

if isempty(get_rootpath(obj)),
    set_rootpath(obj, parentRoot);
end

obj.Parent = abs2rel(parent, get_rootpath(obj));

end