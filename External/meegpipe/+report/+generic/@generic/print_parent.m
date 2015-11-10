function count = print_parent(obj, parent)
% PRINT_PARENT - Print remark syntax indicating parent report
%
% count = print_parent(obj, parent)
%
% Where
%
% PARENT is either a report generator object or directly the name of a
% remark file.
%
% COUNT is the number of characters printed to the open file handle
% associated to report generator OBJ.
%
% See also: print_title, print_code, print_link, print_file_link

% Description: Print remark syntax indicating parent report
% Documentation: class_abstract_generator.txt

import mperl.file.spec.*;

if nargin < 2 || isempty(parent), parent = get_parent(obj); end

if ~isempty(parent),
    
    count = fprintf(get_fid(obj), '[[Parent]]: %s\n\n', parent);
    
else
    
    count = 0;
    
end

end