function fName    = get_filename(obj)
% GET_FILENAME - Get associated report filename
%
% fName = get_filename(obj)
%
% Where
%
% FNAME is the relative path to the remark report file associated with
% report generator object OBJ. FNAME is relative to the root path of OBJ,
% i.e. relative to get_roopath(obj). 
%
% See also: get_abs_filename, abstract_generator

% Description: Get associated report filename
% Documentation: class_abstract_generator.txt

fName = obj.FileName;

end