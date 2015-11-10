function str = char(x, multiline)
% CHAR - Char array conversion
%
% str = char(x)
%
% Where
%
% X is a built-in MATLAB data type or a user-defined data type for which an
% appropriate char() method has been defined.
%
% STR is a character array that may be used to recontruct the input data
% using: eval(str)
%
%
% ## Notes:
%
% * At this moment, the following built-in MATLAB types are supported:
%
%   - numeric arrays (vectors or 2D matrices)
%   - char arrays (vectors or 2D matrices)
%   - structs (limited/experimental support, via xml2struct/struct2xml)
%   - cell arrays of the the types above
%
% See also: xml2struct, struct2xml

import xml.struct2xml;
import misc.matrix2str;
import misc.cell2str;
import mperl.join;

if nargin < 2 || isempty(multiline),
    multiline = true;
end

if isnumeric(x) && ~isa(x, 'pset.mmappset'),
    str = matrix2str(x, multiline);
elseif iscell(x),
    str = cell2str(x, multiline);
elseif isstruct(x),
    str = struct2xml(x);
    str = strrep(str, '''', '''''');
    str = ['xml.xml2struct(''' str ''', true)'];
elseif islogical(x)
    str = mperl.char(double(x));
else
    try
        str = char(x);
    catch ME
        if strcmpi(ME.identifier, 'matlab:invalidconversion'),
            dimStr = regexprep(num2str(size(x)), '\s+', 'x');
            str = sprintf('[%s %s]', dimStr, class(x));
        else
            rethrow(ME);
        end
         
    end
end


end