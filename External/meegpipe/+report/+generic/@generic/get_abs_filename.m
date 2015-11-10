function fName    = get_abs_filename(obj)
% GET_ABS_FILENAME - Get absolute file name of associated report
%
% fName = get_abs_filename(obj)
%
% Where 
%
% OBJ is a report generator and FNAME is the absolute path to the
% associated remark file.
%
% See also: get_filename, abstract_generator

% Description: Get absolute file name of associated report
% Documentation: class_abstract_generator.txt

import mperl.file.spec.catfile;

if isempty(get_filename(obj)),
    fName = '';
    return;
end

fName = catfile(get_rootpath(obj), get_filename(obj));

end