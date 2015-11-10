function str = dimtype_str(x, link)
% DIMTYPE_STR - Returns string describing the types and dimensions of a var
%
% str = dimtype_str(x)
% str = dimtype_str(x, link)
%
% Where
%
% X is a MATLAB variable
%
% LINK is a boolean flag that is set to true will produce a hyperlink
% to the relevant class definition file. This flag is ignored if MATLAB is
% run in terminal mode emulation (option -nodisplay).
%
% STR is a string describing the type and dimensions of X. For instance, if
% X is a 3x1000 double matrix, STR will be '3x1000 double'.
%
% See also: misc

import misc.link2help;

if nargin < 2 || isempty(link), link = false; end

dimsStr = regexprep(num2str(size(x)), '\s+', 'x');
className = class(x);

if link && usejava('Desktop'),
    
    
    mfile = which(className);
    if isempty(strfind(mfile, 'built-in')),
        
        str = link2help(className, className);
        str = sprintf('%s %s', dimsStr, str);
        return;
        
    end
    
end


str = sprintf('%s %s', dimsStr, className);


end