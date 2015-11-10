function charArray = cell2char(cellArray)
% CELL2CHAR - Converts a cell array of strings into a char matrix
%
% import misc.cell2char;
% charArray = cell2char(cellArray)
%
% Where
%
% CELLARRAY is a cell array of strings, e.g. {'str'; 'long_str'}
%
% CHARARRAY is a equivalent char matrix, e.g. 
% cell2char({'str'; 'long_str'}) is equivalent to ['     str'; 'long_str']
%
%
% See also: char2cell 

% Documentation: pkg_misc.txt
% Description: Converts cell array of strings into a char matrix

if ~all(cellfun(@(x) ischar(x) & isvector(x), cellArray)),
    error('Input must be a cell array of strings');
end

maxLength = max(cellfun(@(x) numel(x), cellArray));

charArray = cellfun(@(x) sprintf(['%' num2str(maxLength) 's'], ...
    reshape(x, 1, numel(x))), cellArray, 'UniformOutput', false);
charArray = cell2mat(charArray);





end