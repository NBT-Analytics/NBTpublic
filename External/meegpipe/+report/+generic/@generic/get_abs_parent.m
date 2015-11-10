function parent = get_abs_parent(obj)
% GET_ABS_PARENT - Get absolute path to parent report
%
% parent = get_abs_parent(obj)
%
% Where
%
% PARENT is the absolute path to the parent report of report generator OBJ
%
% See also: get_parent, abstract_generator

% Description: Get absolute path to parent report
% Documentation: class_abstract_generator.txt

import mperl.file.spec.catfile;
import mperl.file.spec.rel2abs;

parent = rel2abs(catfile(get_rootpath(obj), get_parent(obj)));

end