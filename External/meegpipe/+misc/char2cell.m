function cellArray = char2cell(charArray)
% CHAR2CELL - Converts char matrix into cell array of strings
%
% improt misc.char2cell;
% cellArray = char2cell(charArray)
% 
% Where
%
% CHARARRAY is a char matrix, e.g. CHARARRAY = ['     str'; 'long_str']
%
% CELLARRAY is an equivalent cell array of strings, e.g.
% char2cell(['     str'; 'long_str']) produces {'str'; 'long_str'}
%
% See also: cell2char

% Documentation: pkg_misc.txt
% Description: Converts char matrix into cell array of strings

cellArray = mat2cell(charArray, ones(size(charArray,1),1), ...
    size(charArray,2));

cellArray = cellfun(@(x) misc.strtrim(x), cellArray, 'UniformOutput', false);

end