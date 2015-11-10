function count = fprintf(obj, varargin)
% FPRINTF - Prints to report
%
% count = fprintf(obj, input)
%
% Where
%
% INPUT is what is to be printed to report OBJ. INPUT must be a string or a
% printable object.
%
% See also: printable, abstract_generator



if ~initialized(obj), initialize(obj); end

count = fprintf(get_fid(obj), varargin{:});


end