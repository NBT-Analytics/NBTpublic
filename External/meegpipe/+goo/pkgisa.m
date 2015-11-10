function bool = pkgisa(obj, type, basePkg)

import goo.parse_pkg_name;
import goo.pkgisa;

if nargin < 3 || isempty(basePkg),
    
    st = dbstack('-completenames');
    
    if numel(st) >= 2,
        basePkg = parse_pkg_name(st(2).file);
    else
        basePkg = '';
    end
  
end

if iscell(type),
    
   bool = false;
   
   for i = 1:numel(type)
      bool = bool | pkgisa(obj, type{i}, basePkg); 
   end
   
   return;
   
end

origType = type;
type  = [basePkg '.' lower(type)];

bool = isa(obj, type);

if ~bool,
    bool = isa(obj, origType);
end

if ~bool,
   % If still not found, try again in parent package
   
    if ~isempty(regexp(basePkg, '^(.+)\.[^\.]+$', 'once')),
        parentPkg = regexprep(basePkg, '^(.+)\.[^\.]+$', '$1');
        bool = pkgisa(obj, origType, parentPkg);
    end
    
end


end