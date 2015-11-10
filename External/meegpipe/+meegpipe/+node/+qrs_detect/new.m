function obj = new(varargin)

import goo.parse_pkg_name;

pkgName = parse_pkg_name(mfilename('fullpath'));
className = regexprep(pkgName, '.*?(\w+)$', '$1');
obj = eval([pkgName '.' className '(varargin{:})']);


end